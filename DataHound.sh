#!/bin/bash

BOLD="\e[1m"
NORMAL="\e[0m"
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"

HELP="
${BOLD}[+]USAGE:${NORMAL} ./search.sh  (OPTIONS)
-j (string) - search in javascript files
-x (string) - search in header files
-e (string) - search in html files
-n (string) - search nmap scans
-h - help
"

# function to search for expressions in HTML files
searchhtml() {
    local WORD="${1}"
    for domain in $(ls Response-Body); do
        echo -e "\n${BOLD}${YELLOW}${domain}${NORMAL}"
        RES=$(cat Response-Body/$domain | grep -E --color=always "${WORD}")
        if [ $(echo $RES | wc -c) -le 1 ]; then
            echo -e "${BOLD}${RED}No results found${NORMAL}"
        else
            echo -e $RES
        fi
    done
}

# function to search for expressions in header files
searchheader() {
    local WORD="${1}"
    for domain in $(ls Headers); do
        echo -e "\n${BOLD}${YELLOW}${domain}${NORMAL}"
        RES=$(cat Headers/$domain | grep -E --color=always "${WORD}")
        if [ $(echo $RES | wc -c) -le 1 ]; then
            echo -e "${BOLD}${RED}No results found${NORMAL}"
        else
            echo -e $RES
        fi
    done
}

# function to search for expressions in Javascript files
searchjs() {
    local WORD="${1}"
    for domain in $(ls Scripts-Response); do
        for file in $(ls Scripts-Response/$domain); do
            echo -e "\n${BOLD}${YELLOW}${domain}/${file}${NORMAL}"
            RES=$(cat Scripts-Response/$domain/$file | js-beautify | grep --color=always -E "${WORD}")
            if [ $(echo $RES | wc -c) -le 1 ]; then
                echo -e "${BOLD}${RED}No results found${NORMAL}"
            else
                echo -e $RES
            fi
        done
    done
}


# function to search for expressions in nmap scans
searchnmap() {
    local WORD="${1}"
    for domain in $(ls ../Scan/Nmap-scans); do
        echo -e "\n${BOLD}${YELLOW}${domain}${NORMAL}"
        RES=$(cat Nmap-scans/$domain | grep -E --color=always "${WORD}")
        if [ $(echo $RES | wc -c) -le 1 ]; then
            echo -e "${BOLD}${RED}No results found${NORMAL}"
        else
            echo -e $RES
        fi
    done
}

while getopts j:x:e:n:h OPTIONS; do
    case "${OPTIONS}" in
        j) searchjs "${OPTARG}" ;;
        e) searchhtml "${OPTARG}" ;;
        x) searchheader "${OPTARG}" ;;
        n) searchnmap "${OPTARG}" ;;
        h) echo -e "${HELP}" ;;
        *)
            echo -e "${BOLD}${RED}[+] Select a valid option.${NORMAL}\n"
            echo -e "${HELP}"
            exit 1
            ;;
    esac
done
