#!/bin/bash

# === ANSI COLORS ===
BOLD="\e[1m"
NORMAL="\e[0m"
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"

HELP="
${BOLD}[+] USAGE:${NORMAL} ./search.sh [OPTIONS]

Options:
  -j <string>   Search in JavaScript files
  -x <string>   Search in header files
  -e <string>   Search in HTML response bodies
  -n <string>   Search in Nmap scan results
  -i            Case-insensitive search
  -h            Show help menu
"

CASE_FLAG=""
# Flags
while getopts "j:x:e:n:ih" OPTIONS; do
    case "${OPTIONS}" in
        i) CASE_FLAG="-i" ;;
    esac
done

# Reset OPTIND to reprocess options
OPTIND=1

# === GENERIC SEARCH FUNCTION ===
search_in_dir() {
    local DIR="$1"
    local WORD="$2"
    local FILE_GLOB="$3"

    [ ! -d "$DIR" ] && echo -e "${RED}[!] Missing directory: $DIR${NORMAL}" && return

    for target in $(find "$DIR" -type f $FILE_GLOB 2>/dev/null); do
        echo -e "\n${BOLD}${YELLOW}${target}${NORMAL}"
        RES=$(cat "$target" | grep -E --color=always $CASE_FLAG "${WORD}")
        if [ -z "$RES" ]; then
            echo -e "${BOLD}${RED}No results found in $target${NORMAL}"
        else
            echo -e "$RES"
        fi
    done
}

# === JAVASCRIPT SEARCH ===
search_js() {
    local WORD="$1"
    [ ! -d Scripts-Response ] && echo -e "${RED}[!] Scripts-Response directory not found${NORMAL}" && return
    for domain in $(ls Scripts-Response); do
        for file in $(find Scripts-Response/$domain -type f); do
            echo -e "\n${BOLD}${YELLOW}${domain}/${file}${NORMAL}"
            RES=$(js-beautify "$file" | grep -E --color=always $CASE_FLAG "${WORD}")
            if [ -z "$RES" ]; then
                echo -e "${BOLD}${RED}No results found in $file${NORMAL}"
            else
                echo -e "$RES"
            fi
        done
    done
}

# === OPTION DISPATCH ===
while getopts "j:x:e:n:ih" OPTIONS; do
    case "${OPTIONS}" in
        j) search_js "${OPTARG}" ;;
        x) search_in_dir "Headers" "${OPTARG}" ;;
        e) search_in_dir "Response-Body" "${OPTARG}" ;;
        n) search_in_dir "../Scan/Nmap-scans" "${OPTARG}" ;;
        i) ;; # already handled above
        h) echo -e "${HELP}" ;;
        *)
            echo -e "${BOLD}${RED}[!] Invalid option.${NORMAL}\n"
            echo -e "${HELP}"
            exit 1
            ;;
    esac
done
