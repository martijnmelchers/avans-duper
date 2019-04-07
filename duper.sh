#!/bin/bash

# Maak een var directory als hij nog niet bestaat.

mkdir -p ~/var


# files houdt alle unieke shasums van files in om te kijken of we een bestand al hebben gehad
sha_files=()

# duplicates houdt alle bestanden in 
duplicates=()

# Deze bestanden worden genegeerd door de duplicate checker
ignore_duplicates=()

delete_files=false

lang="en"

while getopts "nrx:l:" opt; do
    case $opt in
    n)
        echo "n"
    ;;
    r)
        delete_files=true;
    ;;
    x)
        if [[ -e $OPTARG ]] ; then
            ignore_duplicates+=("$OPTARG")
        else
            echo "Opgegeven bestand(en) zijn niet valide "  
            exit 1;
        fi
    ;;
    l)
        if [[ "$OPTARG" != "" ]] ; then
            lang="$OPTARG";
        else
            lang="nl";
        fi

    ;;
    esac
done

# Controleer of de file wel bestaat zo ja laad de file en zo nee dan sluiten we de script.
if [[ ! -f ${lang}.sh ]]; then
    echo "Language \`${lang}\` not found."
    exit 1;
else
    source $lang.sh
fi

# Zorgt dat we de $1 kunnen aanroepen door alle andere dingen weg te shiften.
shift $((OPTIND-1))


array_contains () {
    local seeking=$1; shift
    local in=1
    for element; do
        if [[ ${element} == ${seeking} ]]; then
            in=0
            break
        fi
    done
    return $in
}

echo "$SCANNING_DIR $1";

while read -r file; do
    echo $PROGRESS_START;

    # Als dit bestand in de exclusie lijst staat ga dan door.
    if array_contains "$file" "${ignore_duplicates[@]}" ; then
        continue
    fi

    echo "$PROGRESS_FILE $file";

    # $file is het pad van de file.
    sha=$( shasum -a 256 "$file"  | awk '{print $1}' )

    echo "$PROGRESS_HASH $sha";

    # Check of we deze sha al zijn tegengekomen in het proces
    if array_contains "$sha" ${sha_files[@]} ; then
        # We hebben een duplicate voeg dit bestandspad aan de lijst toe
        duplicates+=("$file")
         if [[ "$delete_files" = true ]]; then
            rm $file;
            echo $PROGRESS_DELETING;
        fi

        echo "$PROGRESS_STATUS $PROGRESS_MATCH";
    else
        # Dit bestand is nog niet voorgekomen, voeg de sha toe aan de lijst.
        sha_files+=("$sha")
        echo "$PROGRESS_STATUS $PROGRESS_NO_MATCH";
    fi


    echo "-----------------------";

done < <(find "$1" -type f)

echo "Duplicates found:";
# Print het aantal duplicates
printf '%s\n' "${duplicates[@]}"

