#!/bin/bash
scripting_dir=$(dirname "$0")

env_dir="submission_reminder_app/"
cp ./${scripting_dir}/.cache/* ./${scripting_dir}/

dirs=(${env_dir}{app,modules,assets,config})

for d in ${dirs[@]}; do
	if [[ ! -d $d ]]; then
		mkdir -p $d 2> /dev/null
	else
		echo "Directory $d exists"
	fi
done

if [[ $? -ne 0 ]]; then
	echo "Failed to create directories"
	exit 1
fi

files=(config.env functions.sh reminder.sh submissions.txt)
destinations=(config/config.env modules/functions.sh app/reminder.sh assets/submissions.txt)
last_index_of_files="$((${#files[@]}-1))"

for i in $(seq 0 $last_index_of_files); do
	if [[ -f "${files[i]}" ]]; then
		mv "${files[i]}" "$env_dir${destinations[i]}" 2> /dev/null
	else
		echo "File ${files[i]} doesn't exist"
		exit 1
	fi
done

if [[ $? -ne 0 ]]; then
	echo "Failed to move files"
	exit 1
fi

rows="Alice,Python Basics,not submitted\nBob,Data Structures,submitted\nCharlie,Algorithms,not submitted\nDavid,Machine Learning,submitted\nEve,Web Development,not submitted"
records_file="submission_reminder_app/assets/submissions.txt"

if [[ -f $records_file ]]; then
	echo -e $rows >> $records_file 2> /dev/null
else
	echo "File $records_file doesn't exist"
	exit 1
fi

if [[ $? -ne 0 ]]; then
	echo "Failed to add new records to $records_file"
	exit 1
fi

startup_file="${env_dir}startup.sh"
reminder_app="app/reminder.sh"
reminder_file="${env_dir}${reminder_app}"

if [[ -x "${reminder_file}" ]]; then
	echo '#!/bin/bash' > "${startup_file}" 2> /dev/null
	echo 'scripting_dir=$(dirname "$0")' >> "${startup_file}" 2> /dev/null
	echo 'cd ./${scripting_dir}/' >> "${startup_file}" 2> /dev/null
	echo './'"${reminder_app}" >> "${startup_file}" 2> /dev/null
	echo 'cd - > /dev/null' >> "${startup_file}" 2> /dev/null

	chmod u+x "${startup_file}" 2> /dev/null
else
	echo "File ${reminder_file} is not executable"
	exit 1
fi

if [[ $? -ne 0 ]]; then
	echo "Failed to create create $startup_file file"
	exit 1
fi

echo "Environment $env_dir created"
