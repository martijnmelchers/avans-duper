#!/bin/bash

# Maak een var directory als hij nog niet bestaat.

mkdir -p ~/var


# files houdt alle unieke shasums van files in om te kijken of we een bestand al hebben gehad
files=()

# duplicates houdt alle bestanden in 
duplicates=()

while getopts "nx:l:" opt; do
    case $opt in
    n)
        echo "n"
    ;;
    x)
        echo "x"
    ;;
    l)
        echo "l"
    ;;
    esac
done

# Zorgt dat we de $1 kunnen aanroepen door alle andere dingen weg te shiften.
shift $((OPTIND-1))

checkFile(){
    shasum "$1"
}

export -f checkFile 
files+=($(find "$1" -type f -exec bash -c 'checkFile "$0" &' {} \; | awk '{print $1}')) 

# Wacht tot alle files
wait
printf '%s\n' "${files[@]}"

