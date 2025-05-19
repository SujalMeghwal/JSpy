#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# Colors for output
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
MAGENTA="\e[35m"
CYAN="\e[36m"
RESET="\e[0m"

# Input file with domain list
DOMAIN_LIST="${1:-}"

if [[ -z "$DOMAIN_LIST" ]]; then
  echo -e "${RED}Error: No input file provided.${RESET}"
  echo "Usage: $0 domain_list.txt"
  exit 1
fi

if [[ ! -f "$DOMAIN_LIST" ]]; then
  echo -e "${RED}Error: File '$DOMAIN_LIST' not found.${RESET}"
  exit 1
fi

# Check for required commands
for cmd in curl awk grep find js-beautify; do
  if ! command -v "$cmd" &>/dev/null; then
    echo -e "${RED}Error: Required command '$cmd' not found. Please install it.${RESET}"
    exit 1
  fi
done

# Helper: safely read lines from file
read_lines() {
  local file="$1"
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" ]] && continue
    echo "$line"
  done < "$file"
}

# Create necessary directory structure per domain
create_dirs() {
  local domain="$1"
  mkdir -p "$domain/Recon/JS/Headers"
  mkdir -p "$domain/Recon/JS/Response-Body"
  mkdir -p "$domain/Recon/JS/Scripts-Response"
  mkdir -p "$domain/Recon/JS/Endpoints"
  mkdir -p "$domain/Recon/Scan/Nmap-Scans"
}

# Extract domain name from URL
get_domain_name() {
  local url="$1"
  echo "$url" | awk -F/ '{print $3}'
}

# Fetch headers and response body for each URL
fetch_headers_and_body() {
  local domain="$1"
  local url_file="$domain/alive.txt"

  if [[ ! -f "$url_file" ]]; then
    echo -e "${YELLOW}Warning: No alive.txt found for domain $domain. Skipping.${RESET}"
    return
  fi

  while IFS= read -r url || [[ -n "$url" ]]; do
    [[ -z "$url" ]] && continue
    local domain_name
    domain_name=$(get_domain_name "$url")

    echo -e "${BLUE}Fetching headers for ${GREEN}$url${RESET}"
    if ! curl -sSf -H "X-Forwarded-For: evil.com" -I "$url" > "$domain/Recon/JS/Headers/$domain_name"; then
      echo -e "${RED}Failed to get headers for $url${RESET}"
      continue
    fi

    echo -e "${BLUE}Fetching response body for ${GREEN}$url${RESET}"
    if ! curl -sSf -H "X-Forwarded-For: evil.com" -L "$url" > "$domain/Recon/JS/Response-Body/$domain_name"; then
      echo -e "${RED}Failed to get response body for $url${RESET}"
      continue
    fi

    echo -e "${GREEN}Finished processing $url${RESET}"
  done < "$url_file"
}

# Extract and download scripts referenced in response bodies
extract_and_download_scripts() {
  local domain="$1"
  local url_file="$domain/alive.txt"

  while IFS= read -r url || [[ -n "$url" ]]; do
    [[ -z "$url" ]] && continue
    local domain_name
    domain_name=$(get_domain_name "$url")

    echo -e "${MAGENTA}Processing scripts for ${CYAN}$domain_name${RESET}"

    local response_file="$domain/Recon/JS/Response-Body/$domain_name"
    if [[ ! -f "$response_file" ]]; then
      echo -e "${YELLOW}No response body for $domain_name, skipping script extraction.${RESET}"
      continue
    fi

    local endpoints
    endpoints=$(grep -Eoi 'src="[^"]+"' "$response_file" | cut -d '"' -f 2 || true)

    mkdir -p "$domain/Recon/JS/Scripts-Response/$domain_name"

    while IFS= read -r endpoint; do
      [[ -z "$endpoint" ]] && continue
      local url_to_fetch="$endpoint"

      # If endpoint is relative, prepend domain
      if [[ ! "$endpoint" =~ ^https?:// ]]; then
        url_to_fetch="https://$domain_name$endpoint"
      fi

      local filename
      filename=$(basename "$endpoint")

      echo -e "${GREEN}Downloading script: $filename from $url_to_fetch${RESET}"

      if ! curl -sSf -L "$url_to_fetch" -o "$domain/Recon/JS/Scripts-Response/$domain_name/$filename"; then
        echo -e "${RED}Failed to download script $filename from $url_to_fetch${RESET}"
      fi
    done <<< "$endpoints"
  done < "$url_file"
}

# Extract relative URLs from downloaded scripts using relative-url-extractor
extract_relative_urls() {
  local domain="$1"
  local url_file="$domain/alive.txt"

  local extractor_path="/root/Tool/relative-url-extractor/extract.rb"
  if [[ ! -x "$extractor_path" ]]; then
    echo -e "${RED}Error: Relative URL extractor script not found or not executable at $extractor_path.${RESET}"
    return
  fi

  while IFS= read -r url || [[ -n "$url" ]]; do
    [[ -z "$url" ]] && continue
    local domain_name
    domain_name=$(get_domain_name "$url")

    local script_dir="$domain/Recon/JS/Scripts-Response/$domain_name"
    local output_dir="$domain/Recon/JS/Endpoints/$domain_name"
    mkdir -p "$output_dir"

    echo -e "${GREEN}Extracting relative URLs from scripts for $domain_name${RESET}"

    for script_file in "$script_dir"/*; do
      [[ -f "$script_file" ]] || continue
      ruby "$extractor_path" < "$script_file" >> "$output_dir/$(basename "$script_file")"
    done

    # Clean empty directories
    find "$domain/Recon/JS/Endpoints" -type d -empty -delete
  done < "$url_file"
}

# Beautify JavaScript files
beautify_scripts() {
  local domain="$1"
  local js_dir="$domain/Recon/JS/Scripts-Response"

  if ! command -v js-beautify &>/dev/null; then
    echo -e "${YELLOW}Warning: js-beautify not installed. Skipping beautification.${RESET}"
    return
  fi

  echo -e "${BLUE}Beautifying JS scripts in $js_dir${RESET}"

  find "$js_dir" -type f -name '*.js' | while read -r jsfile; do
    echo -e "${BLUE}Beautifying $jsfile${RESET}"
    js-beautify -r "$jsfile"
  done
}

# (Optional) Run nmap scan (disabled by default)
run_nmap_scan() {
  local domain="$1"
  local url_file="$domain/alive.txt"
  local output_dir="$domain/Recon/Scan/Nmap-Scans"

  mkdir -p "$output_dir"

  while IFS= read -r url || [[ -n "$url" ]]; do
    [[ -z "$url" ]] && continue
    local domain_name
    domain_name=$(get_domain_name "$url")

    echo -e "${CYAN}Running nmap scan on $domain_name${RESET}"
    nmap -sC -sV "$domain_name" | tee "$output_dir/$domain_name.nmap"
  done < "$url_file"
}

# Main workflow
main() {
  while IFS= read -r domain || [[ -n "$domain" ]]; do
    [[ -z "$domain" ]] && continue
    echo -e "${BOLD}${CYAN}Starting reconnaissance for domain: $domain${RESET}"
    create_dirs "$domain"
    fetch_headers_and_body "$domain"
    extract_and_download_scripts "$domain"
    extract_relative_urls "$domain"
    beautify_scripts "$domain"
    # run_nmap_scan "$domain"   # Uncomment to enable nmap scans
    echo -e "${GREEN}Finished reconnaissance for domain: $domain${RESET}\n"
  done < "$DOMAIN_LIST"
}

main
