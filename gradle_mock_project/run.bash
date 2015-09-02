#!/bin/bash

# 0. Define functions and hooks

trap _restore EXIT

function _help {
	printf "Usage: run.bash gradle_compile_statement_for_library\n"
	exit 0
}

function copyClassesFile {
	local local_dir=$1
	local parent_dir=$2
	local dest_dir=$3
	local group_id=$4
	local artifact_id=$5
	local counter=$6
	local local_version=""

	cd $local_dir
	for dir in *; do
		local_version="$dir"
		if [[ "$parent_dir" == *"$ARTIFACT_ID"* ]]; then 
			VERSION="$local_version"
		fi
	done

	local jar_name="$counter-$parent_dir-$local_dir-$local_version-classes.jar"
	cd $local_version/jars
	cp classes.jar $jar_name
	cp $jar_name $BASE_DIR/$dest_dir
	cd ../../../
}

function _restore {
	if [ "$VERBOSE" == true ]; then 
  		echo "\n (Restoring base project..)"
  	fi
  	cd $BASE_DIR
  	if [ -e "build.gradle" ]; then
		rm build.gradle 2> /dev/null
		rm -rf $CLASSES_DIR 2> /dev/null
		rm -rf dependencies
  	fi
  	rm -r build 2> /dev/null
  	cp "build.gradle.base" "build.gradle"
}

function tokenizeLibraryFQN {
	local library_fqn=$1
	declare -a PARTS
	COUNTER=0
	tokenized_group_id=""
	tokenized_artifact_id=""
	tokenized_version=""
	IFS=':' read -ra ADDR <<< "$library_fqn"
	for i in "${ADDR[@]}"; do
		PARTS[COUNTER]=$i
		COUNTER=$((COUNTER+1))
	done
	tokenized_group_id="${PARTS[0]}"
	tokenized_artifact_id="${PARTS[1]}"
	tokenized_version="${PARTS[2]}"
}

STARTTIME=$(date +%s)

BASE_DIR=`pwd`
ARCHIVE_FQN=$1
GROUP_ID=""
ARTIFACT_ID=""
VERSION=""
CLASSES_DIR="extracted-libs"

if [ -z "$ARCHIVE_FQN" ]; then
	_help
fi

PRINT_OUTPUT=false
VERBOSE=false

# 1. Process input parameter
if [ "$VERBOSE" == true ]; then 
	echo "1. Process input parameter"
fi

mkdir -p $CLASSES_DIR
cp -f "build.gradle.base" "build.gradle"

tokenizeLibraryFQN "$ARCHIVE_FQN"

GROUP_ID="$tokenized_group_id"
ARTIFACT_ID="$tokenized_artifact_id"
VERSION="$tokenized_version"

# 2. Replace the dummy 'compile' statement of build.gradle
if [ "$VERBOSE" == true ]; then 
	echo "2. Replace the dummy \'compile\' statement of build.gradle"
fi

sed -i "s/dummy/${ARCHIVE_FQN}/g" build.gradle

# 3. Run the build
if [ "$VERBOSE" == true ]; then 
	echo "3. Run the build"
fi

./gradlew -q assembleDebug
build_successful=$?

if [ $build_successful -ne 0 ]; then
	if [ "$VERBOSE" == true ]; then 
		echo "3. Build failed, ABORTING"
	fi
	exit -1;
fi

# 4. Cd into build/intermediates/exploded-aar/$LIBRARY_NAME
if [ "$VERBOSE" == true ]; then 
	echo "4. For each sub-module, copy 'classes.jar' to $CLASSES_DIR"
fi

USE_ALTERNATIVE_DIR=false
exploded_aar_dir="build/intermediates/exploded-aar"
if ! [ -e $exploded_aar_dir ]; then
	cd dependencies
	USE_ALTERNATIVE_DIR=true
else
	cd $exploded_aar_dir
fi

COUNTER=0
declare -a SUBS
for ext_dir in *; do
	if ! [ -f $ext_dir ]; then
		cd $ext_dir
		for dir in *; do
			dependency_name=`copyClassesFile $dir $ext_dir $CLASSES_DIR $GROUP_ID $ARTIFACT_ID $COUNTER`
			SUBS[COUNTER]="$dependency_name"
			COUNTER=$((COUNTER+1))
		done
		cd ..
	else
		SUBS[COUNTER]="$ext_dir"
		cp "$ext_dir" "$BASE_DIR/$CLASSES_DIR/"
		COUNTER=$((COUNTER+1))
	fi
done

cd $BASE_DIR/$CLASSES_DIR

# 5. Build file list
if [ "$VERBOSE" == true ]; then 
	echo "5. Build file list, create temporary DEX file and count methods"
fi

COUNTER=0
TOTAL=0
SELECTED=0
declare -a SUBS_COUNT
declare -a SUBS_SIZE
for file in *; do
	SUBS_SIZE[COUNTER]=`stat -f%z $file`
	dx --dex --output=temp.dex $file
  	SUBS_COUNT[COUNTER]=`cat temp.dex | head -c 92 | tail -c 4 | hexdump -e '1/4 "%d\n"'`
  	TOTAL=$((TOTAL+${SUBS_COUNT[COUNTER]}))
  	if [[ "${SUBS[COUNTER]}" == *"$ARTIFACT_ID"* ]]; then
  		SELECTED="${SUBS_COUNT[COUNTER]}";
  	fi
  	COUNTER=$((COUNTER+1))
  	rm temp.dex
done

cd $BASE_DIR

ENDTIME=$(date +%s)

# 6. Return result
if [ "$PRINT_OUTPUT" == true ]; then
	echo "\n\n\t\t COUNT FOR $ARCHIVE_FQN:\t -- $SELECTED -- \n"
	for i in ${!SUBS[@]}; do
		current_sub="${SUBS[i]}"
		current_sub_count="${SUBS_COUNT[i]}"
		echo "\t\t $current_sub -- $current_sub_count"
	done
	echo "\n\t\t TOTAL COUNT FOR $ARCHIVE_FQN:\t -- $TOTAL -- \n"

	echo "\n\n Computational time: $(($ENDTIME - $STARTTIME)) seconds"
fi
