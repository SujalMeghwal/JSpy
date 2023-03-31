#!/bin/bash
range=$1

# Create directories for storing output
make-dir(){
    for domain in $(cat $range); do
        mkdir -p "$domain/Recon"
        mkdir -p "$domain/Recon/JS"
        mkdir -p "$domain/Recon/JS/Headers"
        mkdir -p "$domain/Recon/JS/Response-Body"
        mkdir -p "$domain/Recon/JS/Scripts"
        mkdir -p "$domain/Recon/JS/Scripts-Response"
        mkdir -p "$domain/Recon/JS/Endpoints"
        mkdir -p "$domain/Recon/Scan/Nmap-scans"
    done
}
# Function call
make-dir

# Colors
RED="\e[31m"
GREEN="\e[32m"
ENDCOLOR="\e[0m"
NC='\033[0m'
ORED='\033[0;31m'

# Loop through the domains in the input file and run curl commands
Extract-Header(){
    for domain in $(cat "$range"); do
        for x in $(cat "$domain/alive.txt"); do
            # Extract domain name from URL
            NAME=$(echo "$x" | awk -F/ '{print $3}')

            # Get Headers and save to file
            printf "Getting headers for ${GREEN}$x${NC}...\n"
            curl -sSf -X GET -H "X-Forwarded-For: evil.com" "$x" -I > "$domain/Recon/JS/Headers/$NAME"
            if [ $? -ne 0 ]; then
                printf "${RED}Failed to get headers for $x.${NC}\n"
                continue
            fi

            # Get response body and save to file
            printf "Getting response body for ${GREEN}$x${NC}...\n"
            curl -sSf -X GET -H "X-Forwarded-For: evil.com" -L "$x" > "$domain/Recon/JS/Response-Body/$NAME"
            if [ $? -ne 0 ]; then
                printf "${RED}Failed to get response body for $x.${NC}\n"
                continue
            fi

            printf "${GREEN}Finished processing $x.${NC}\n\n"
        done
    done
}
Extract-Header
# Extract script endpoints and download scripts
extract-exd(){
    for domain in $(cat $range); do
        for x in $(cat "$domain/alive.txt"); do
            # Extract domain name from URL
            NAME=$(echo $x | awk -F/ '{print $3}')

            # Extract script Endpoints from response body and download Scripts
            printf "\n\n${RED}$NAME${NC}\n\n"
            END_POINTS=$(cat "$domain/Recon/JS/Response-Body/$NAME" | grep -Eoi "src=\"[^>]+></script>" | cut -d '"' -f 2)
            for end_point in $END_POINTS; do
                len=$(echo $end_point | grep "http" | wc -c)
                mkdir -p "$domain/Recon/JS/Scripts-Response/$NAME/"
                URL=$end_point
                if [ $len == 0 ]; then
                    URL="https://$NAME$end_point"
                fi
                file=$(basename $end_point)
                curl -X GET $URL -L > "$domain/Recon/JS/Scripts-Response/$NAME/$file"
                echo $URL >> "$domain/Recon/JS/Scripts/$NAME"
            done
        done
    done
}
extract-exd
extract-js() {
    set -e # exit immediately if any command fails
    for domain in $(cat $range); do
        for x in $(cat "$domain/alive.txt"); do
            # Extract domain name from URL
            NAME=$(echo $x | awk -F/ '{print $3}')

            # Create directory for storing output
            mkdir -p "$domain/Recon/JS/Endpoints/$NAME"

            # Extract relative URLs from scripts and save to file
            printf "\n\e[32m[+] Extracting endpoints from scripts for $NAME\e[0m\n"
            for file in $(ls "$domain/Recon/JS/Scripts-Response/$NAME"); do
            cat "$domain/Recon/JS/Scripts-Response/$NAME/$file" | /root/Tool/relative-url-extractor/extract.rb  >> "$domain/Recon/JS/Endpoints/$NAME/$file"
            
            # Remove Empty directory   
            find "$domain/Recon/JS/Endpoints/" -depth -type d -empty -exec rmdir {} \;
            done
        done
    done
}
extract-js
# Run nmap scan on the domains
scan-nmap(){
    for domain in $(cat $range); do
        for x in $(cat "$domain/alive.txt"); do
            NAME=$(echo $x | awk -F/ '{print $3}')
            # Run nmap scan on the domain and save output to file
            nmap -sC -sV $NAME | tee $domain/Recon/Scan/Nmap-scans/$NAME
        done
    done
}
scan-nmap
