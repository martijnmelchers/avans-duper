#!/bin/bash


# Maak een var directory als hij nog niet bestaat.

mkdir -p ~/var
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