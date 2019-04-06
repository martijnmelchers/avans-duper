#!/bin/bash

# Maak een var directory als hij nog niet bestaat.

mkdir -p ~/var


# files houdt alle unieke shasums van files in om te kijken of we een bestand al hebben gehad
sha_files=()

# duplicates houdt alle bestanden in 
duplicates=()

# Deze bestanden worden genegeerd door de duplicate checker
ignore_duplicates=()

while getopts "nx:l:" opt; do
    case $opt in
    n)
        echo "n"
    ;;
    x)
        if [ -e $OPTARG ] ; then
            ignore_duplicates+=("$OPTARG")
        else
            echo "Opgegeven bestand(en) zijn niet valide "  
            exit 1;
        fi
    ;;
    l)
        echo "l"
    ;;
    esac
done

# Zorgt dat we de $1 kunnen aanroepen door alle andere dingen weg te shiften.
shift $((OPTIND-1))


array_contains () {
    local seeking=$1; shift
    local in=1
    for element; do
        if [[ $element == $seeking ]]; then
            in=0
            break
        fi
    done
    return $in
}

while read -r file; do
    # Als dit bestand in de exclusie lijst staat ga dan door.
    if array_contains "$file" "${ignore_duplicates[@]}" ; then
        continue
    fi

    # $file is het pad van de file.
    sha=$( shasum -a 256 "$file" | awk '{print $1}' )

    # Check of we deze sha al zijn tegengekomen in het proces
    if array_contains "$sha" ${sha_files[@]} ; then
        # We hebben een duplicate voeg dit bestandspad aan de lijst toe
        duplicates+=("$file")
    else
        # Dit bestand is nog niet voorgekomen, voeg de sha toe aan de lijst.
        sha_files+=("$sha")
    fi
done < <(find "$1" -type f)



# Print het aantal duplicates
printf '%s\n' "${duplicates[@]}"

