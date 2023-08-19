#!/bin/bash

verbose=false
recursive=false
archives_decompressed=0
files_not_decompressed=0


unpack_archive() {
    local archive="$1"
    local destination_dir="$(dirname "$archive")"
    local file_name="$(basename "$archive")"
    
    case "$(file -b "$archive")" in
        *"gzip compressed"*) tar -xzf "$archive" -C "$destination_dir" ;;
        *"bzip2 compressed"*) tar -xjf "$archive" -C "$destination_dir" ;;
        *"Zip archive"*) unzip "$archive" -d "$destination_dir" ;;
        *"compress'd"*) uncompress "$archive" ;;
        *) return 1 ;;
    esac
    
    if [ $? -eq 0 ]; then
        archives_decompressed=$((archives_decompressed + 1))
        if [ "$verbose" = true ]; then
            echo "Unpacking $file_name..."
        fi
    else
        files_not_decompressed=$((files_not_decompressed + 1))
        if [ "$verbose" = true ]; then
            echo "Ignoring $file_name"
        fi
    fi
}

unpack_recursive() {
    local path="$1"
    
    if [ -d "$path" ]; then
        for item in "$path"/*; do
            if [ -d "$item" ]; then
                unpack_recursive "$item"
            elif [ -f "$item" ]; then
                unpack_archive "$item"
            fi
        done
    fi
}

while getopts "rv" opt; do
    case $opt in
        r) recursive=true ;;
        v) verbose=true ;;
        *) echo -e "Invalid\nUsage: unpack [-r] [-v] file [file...]"
    	    exit 1 ;;
    esac
done

shift $((OPTIND - 1))

if [ $# -eq 0 ]; then
    echo -e "Invalid\nUsage: unpack [-r] [-v] file [file...]"
    exit 1
fi

for arg in "$@"; do
    if [ -f "$arg" ]; then
        unpack_archive "$arg"
    elif [ -d "$arg" ] && [ "$recursive" = true ]; then
        unpack_recursive "$arg"
    fi
done

echo "Decompressed $archives_decompressed archive(s)"
exit $files_not_decompressed


