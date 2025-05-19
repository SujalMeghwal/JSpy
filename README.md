# 🕵️‍♂️ JSpy
JSpy is a powerful reconnaissance tool designed to automate the process of gathering information about a list of domains. It creates output directories for each domain, extracts headers and response bodies, script endpoints and relative URLs, and runs nmap scans. Whether you're a bug bounty hunter, pen tester, or security researcher, JSpy is an essential tool for any reconnaissance mission. With JSpy, you can save time and increase your chances of finding vulnerabilities in your target domains.

## 🚀 Features:
* 📥 Extracts response headers and HTML bodies
* 📜 Downloads JavaScript files from live subdomains
* 🧠 Extracts endpoints and relative URLs using relative-url-extractor
* 🔍 Runs Nmap scans for basic service enumeration
* 📁 Organized output per target, ready for offline analysis

## 📖 Requirements
Ensure the following tools are installed:
- `bash`, `curl`, `awk`, `grep`, `find`, `tee`, `rmdir`
- `nmap`
- `js-beautify` (install with: `npm install -g js-beautify`)
- `ruby`
- `relative-url-extractor` (https://github.com/jobertabma/relative-url-extractor)

## ⚙️ Setup
# 1. Prepare your target list:
```bash
echo example.com > scope.txt
```
# 2. Clone the relative URL extractor:
```bash
mkdir -p /root/Tools/
cd /root/Tools/
git clone https://github.com/jobertabma/relative-url-extractor.git
```
# 3. Create your alive.txt file with live subdomains (use http/https):
```bash
cat > alive.txt <<EOF
https://sub1.example.com
https://sub2.example.com
http://sub3.example.com
EOF
```
# 4. Setup directory structure:
```bash
mkdir example.com
mv alive.txt example.com/
```
# 5. Clone and run JSpy:
```bash
git clone https://github.com/SecuritySphinx/JSpy.git
cd JSpy
echo example.com > scope.txt
bash jspy.sh scope.txt
```

# 🐕 DataHound – Recon Keyword Search Utility
DataHound is a powerful post-recon search tool. It recursively scans recon output (JS, HTML, headers, and Nmap scans) to uncover interesting strings and keywords.
## 🔧 Usage
```bash
./search.sh [options]
```
## 🔍 Options
```bash
  -j <string>   Search JavaScript files
  -x <string>   Search header files
  -e <string>   Search HTML response bodies
  -n <string>   Search Nmap scan results
  -h            Show help menu
```
## 🧪 Examples
```bash
./search.sh -j "admin"          # Find "admin" in JS files  
./search.sh -x "nginx"          # Look for "nginx" in headers  
./search.sh -e "s3.amazonaws"   # Identify S3 links in HTML  
./search.sh -n "ssh"            # Locate SSH ports in Nmap scans
```
💡 Place `search.sh` inside the target's JS folder for scoped analysis.
## 🧰 Future Enhancements
- Add parallel execution with GNU Parallel for faster scans
- Include output in JSON for structured parsing
- Integrate `gau`, `waybackurls`, or `hakrawler` for deeper URL collection
- Enhance DataHound to parse open ports/services into actionable leads
- Add CVE signature detection or passive technology fingerprinting
