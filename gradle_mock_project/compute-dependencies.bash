#!/bin/bash

function _restore_workspace {
  	if [ -e "build.gradle" ]; then
		rm build.gradle 2> /dev/null
		rm -rf $CLASSES_DIR 2> /dev/null
		rm -rf dependencies
  	fi
  	rm -r build 2> /dev/null
  	cp "build.gradle.base" "build.gradle"
}

library_fqn=$1

if [ -z $library_fqn ]; then
	exit -1;
fi

cp -f "build.gradle.base" "build.gradle"
sed -i "s/dummy/${library_fqn}/g" build.gradle

deps_raw=`./gradlew dependencies`

deps_extracted=""
capture=false

extracted_library_fqn=""
declare -a extracted_deps_fqn

while IFS=$'\n' read line; do 
	if [[ "$line" == "default -"* ]] && [ "$capture" == false ] ; then 
		capture=true
		continue
	fi

	if [[ "$line" == "default-"* ]]; then
		capture=false
		break
	fi

	if [ "$capture" == true ]; then
		deps_extracted="$deps_extracted\n$line"
		case "$line" in
			("-"*) extracted_library_fqn="$line"
			;;
			("     +"*) extracted_deps_fqn+=("$line")
			;;
			("     -"*) extracted_deps_fqn+=("$line")
			;;
		esac
	fi
done <<< "$deps_raw"

if [[ $extracted_library_fqn == *"+"* ]]; then
	extracted_library_fqn=`echo "$extracted_library_fqn" | sed -e 's/---[[:space:]]*\([^->]*\)->[[:space:]]*\(.*\)/\1\2/' -e 's/\([^\+]*\)[^[[:space:]]]*\(.*\)/\1\2/' | tr -d '[[:space:]]'`
else
	extracted_library_fqn=`echo "$extracted_library_fqn" | sed -e 's/---[[:space:]]*\(.*\)/\1/'`
fi

for i in ${!extracted_deps_fqn[@]}; do
	extracted_deps_fqn[i]=`echo "${extracted_deps_fqn[i]}" | tr -d '[[:space:]]' | tr -d '+' | sed 's/---\(.*\)/\1/'`
done

_restore_workspace
