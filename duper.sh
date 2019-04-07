#!/bin/bash

# Door:
# - Sascha Mendel, 2141142
# - Martijn Melchers, 2139354

# Eisen:
# - Alleen bestanden in opgegeven start-directory (inclusief onderliggende directories) worden bekeken
# - Duplicaten van bestanden worden correct gevonden. Je mag hiervoor geen bestaand tool gebruiken 
# - Verplicht getopts gebruiken voor het interpreteren van opties
# - optie -r om gevonden duplicaten direct te laten verwijderen;
# - optie -x <naam> om een file op te geven die buiten beschouwing gelaten moet worden bij het zoeken naar duplicaten.
# - optie -l <landcode> om een landcode in 2 letters mee te geven.
# - het script geeft aan welke duplicaten er gevonden zijn en wat de actie was.
# - Het script maakt een directory ~/var en voegt regels aan een log file toe (duper.log)
# - Het script geeft foutmeldingen bij de gevallen die blackboard meld.

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


start_datetime=$(date "+%F/%r")


usage() {
    echo "Usage: duper [-l lang]] [-r] [-x [file]] [directory]";
    exit 1;
}

while getopts "rx:l:" opt; do
    case $opt in
    r)
        delete_files=true;
    ;;
    x)
        if [[ -f $OPTARG ]] ; then
            ignore_duplicates+=("$OPTARG")
        else
            echo "Not a valid file."  
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

    ?)
        usage
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

if [[ ! -d "$1" ]] ; then
    echo "$NO_VALID_DIR"  
    exit 1;
fi

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


delete_files_count=0;

while read -r file; do
    echo $PROGRESS_START;



    echo "$PROGRESS_FILE $file";

    # $file is het pad van de file.
    sha=$( shasum -a 256 "$file"  | awk '{print $1}' )

    echo "$PROGRESS_HASH $sha";

    # Check of we deze sha al zijn tegengekomen in het proces
    if array_contains "$sha" ${sha_files[@]} ; then
        # Als dit bestand in de exclusie lijst staat ga dan door.
        if array_contains "$file" "${ignore_duplicates[@]}" ; then
            continue
        fi

        # We hebben een duplicate voeg dit bestandspad aan de lijst toe
        duplicates+=("$file")
         if [[ "$delete_files" = true ]]; then
            rm $file;
            delete_files_count=$((delete_files_count + 1))
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
end_datetime=$(date "+%F/%r")

printf '%s /// %s : %s:  %s,  %s:  %s\n' "$start_datetime" "$end_datetime" "$FOUND" "${#duplicates[@]}" "$DELETED" "$delete_files_count" >> ~/var/duper.log

echo $DUPLICATES_FOUND;
# Print het aantal duplicates
printf '%s\n' "${duplicates[@]}"

