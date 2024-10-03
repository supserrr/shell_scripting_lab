#!/bin/bash
scripting_dir=$(dirname "$0")
cd ./${scripting_dir}/
./app/reminder.sh
cd - > /dev/null
