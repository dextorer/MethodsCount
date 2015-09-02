#!/bin/sh

db_user="lmc"
db_pwd="***REMOVED***"
db_name="methods_count"

library_name=$1

already_computed_names=false
if [[ "$library_name" == *"+" ]]; then
	# 0. Analyze dependencies for a better database lookup
	cd gradle_mock_project
	source compute-dependencies.bash "$library_name"
	library_name="$extracted_library_fqn"
	cd ..
	already_computed_names=true
fi

# 1. Connect to database and check if the result has been previously calculated
library_id=`mysql --defaults-extra-file=.db_config.cnf -N -B --database=$db_name -e "select id from libraries where fqn = '$library_name';"`
if [ ! -z "$library_id" ]; then
	# 1a. Retrieve result and dependencies
	library_count=`mysql --defaults-extra-file=.db_config.cnf -N -B --database=$db_name -e "select count from libraries where fqn = '$library_name';"`
	library_size=`mysql --defaults-extra-file=.db_config.cnf -N -B --database=$db_name -e "select size from libraries where fqn = '$library_name';"`
	dependencies_count=`mysql --defaults-extra-file=.db_config.cnf -N -B --database=$db_name -e "SELECT fqn,count,size FROM libraries WHERE id = ANY (SELECT dependency_id FROM libraries JOIN dependencies ON libraries.id = dependencies.library_id WHERE dependencies.library_id = '$library_id');"`
	declare -a dep_fqn
	declare -a dep_count
	declare -a dep_size
	counter=0
	while IFS=$' \t\n' read -a array; do
		dep_fqn[counter]="${array[0]}"
		dep_count[counter]="${array[1]}"
		dep_size[counter]="${array[2]}"
		counter="$((counter + 1))"
	done <<< "$dependencies_count"
	# 1b. Return result
	result="{\"library_fqn\":\"$library_name\",\"library_methods\":$library_count,\"library_size\":$library_size,\"dependencies_count\":$counter,\"dependencies\":["
	for (( i=0; i<$counter; i++ )); do
		result="$result{\"dependency_name\":\"${dep_fqn[i]}\",\"dependency_count\":${dep_count[i]}, \"dependency_size\":${dep_size[i]}},"
	done
	result="${result%?}"
	result="$result]}"
	echo "$result"
	exit 0
fi

# 2. Compute library methods count

cd gradle_mock_project
source run.bash "$library_name"
cd ..

should_update_library_names=false
if [ "$USE_ALTERNATIVE_DIR" == true ] && [ "$already_computed_names" == false ]; then
	cd gradle_mock_project
	source compute-dependencies.bash "$library_name"
	library_name="$extracted_library_fqn"
	cd ..
	should_update_library_names=true
fi

# 3. Update database

if [ "$should_update_library_names" == true ]; then
	for i in ${!SUBS[@]}; do
		SUBS[i]=${SUBS[i]%.*}
		SUBS[i]=`echo "${SUBS[i]}" | sed 's/-/:/'`
	done
fi

declare -a deps_name
declare -a deps_count
declare -a deps_size
for i in ${!SUBS[@]}; do
	current_sub="${SUBS[i]}"
	current_sub_count="${SUBS_COUNT[i]}"
	current_sub_size="${SUBS_SIZE[i]}"
	library_fqn="$GROUP_ID:$ARTIFACT_ID:$VERSION"
	is_contained=false
	if test "${extracted_library_fqn#*$current_sub}" != "$extracted_library_fqn"; then
        is_contained=true    # $substring is in $string
    fi
	if [[ "$is_contained" == true ]]; then
		current_sub="$extracted_library_fqn"
		SUBS[i]="$extracted_library_fqn"
	else
		for j in ${extracted_deps_fqn[@]}; do
			if test "${j#*$current_sub}" != "$j"; then
				current_sub="$j"
				SUBS[i]="$j"
				break;
			fi
		done
	fi
	if [[ "$current_sub" == *"$GROUP_ID:$ARTIFACT_ID:$VERSION" ]]; then
		`mysql --defaults-extra-file=.db_config.cnf -N -B --database=$db_name -e "INSERT INTO libraries (fqn, group_id, artifact_id, version, count, size) VALUES (\"$library_fqn\", \"$GROUP_ID\", \"$ARTIFACT_ID\", \"$VERSION\", \"$current_sub_count\", \"$current_sub_size\");"`		
		deps_name=(${SUBS[@]/$current_sub})
		deps_count=(${SUBS_COUNT[@]/$current_sub_count})
		deps_size=(${SUBS_SIZE[@]/$current_sub_size})
		result="{\"library_fqn\":\"$library_fqn\",\"library_methods\":$current_sub_count,\"library_size\":$current_sub_size,\"dependencies_count\":${#deps_name[@]}"
	fi
done

result="$result,\"dependencies\":["

library_id=`mysql --defaults-extra-file=.db_config.cnf -N -B --database=$db_name -e "SELECT id FROM libraries WHERE fqn=\"$library_fqn\";"`

for i in ${!deps_name[@]}; do
	current_dep="${deps_name[i]}"
	current_dep_count="${deps_count[i]}"
	current_dep_size="${deps_size[i]}"
	tokenizeLibraryFQN "$current_dep"
	current_dep_group_id="$tokenized_group_id"
	current_dep_artifact_id="$tokenized_artifact_id"
	current_dep_version="$tokenized_version"
	`mysql --defaults-extra-file=.db_config.cnf -N -B --database=$db_name -e "INSERT INTO libraries (fqn, group_id, artifact_id, version, count, size) VALUES (\"$current_dep\", \"$current_dep_group_id\", \"$current_dep_artifact_id\", \"$current_dep_version\", \"$current_dep_count\", \"$current_dep_size\");"`		
	current_dep_id=`mysql --defaults-extra-file=.db_config.cnf -N -B --database=$db_name -e "SELECT id FROM libraries WHERE fqn=\"$current_dep\";"`
	`mysql --defaults-extra-file=.db_config.cnf -N -B --database=$db_name -e "INSERT INTO dependencies (library_id, dependency_id) VALUES (\"$library_id\", \"$current_dep_id\");"`
	result="$result{\"dependency_name\":\"$current_dep\",\"dependency_count\":$current_dep_count,\"dependency_size\":$current_dep_size},"
done

if [ "${#deps_name[@]}" -gt 0 ]; then
	result="${result%?}"
fi

result="$result]}"

# 4. Return result
echo "$result"

