#!/bin/bash

exe_name=""
count=-1
timeout=1
user=""

usage_output() {
    echo "Usage: psping [-c ###] [-t ###] [-u user-name] exe-name"
    exit 1
}

while getopts ":c:t:u:" opt; do
    case $opt in
        c)
            count="$OPTARG";;
        t)
            timeout="$OPTARG";;
        u)
            user="$OPTARG";;
        \?)
            echo "Invalid option: -$OPTARG"
            usage_output;;
        :)
            echo "Option -$OPTARG requires an argument."
            usage_output;;
    esac
done
shift $((OPTIND-1))

if [ $# -eq 0 ]; then
    echo "Executable name is required."
    usage_output
fi

exe_name="$1"

count_processes() {
    if [ -n "$user" ]; then
        num_processes=$(pgrep -c -u "$user" "$exe_name")
    else
        num_processes=$(pgrep -c "$exe_name")
    fi
    echo "$exe_name: $num_processes instance(s)..."
}

while [ $count -ne 0 ]; do
    count_processes
    if [ $count -gt 0 ]; then
        count=$((count-1))
    fi
    sleep "$timeout"
done

exit 0

