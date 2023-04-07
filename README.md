# 🕵️‍♂️ JSpy
JSpy is a powerful reconnaissance tool designed to automate the process of gathering information about a list of domains. It creates output directories for each domain, extracts headers and response bodies, script endpoints and relative URLs, and runs nmap scans. Whether you're a bug bounty hunter, pen tester, or security researcher, JSpy is an essential tool for any reconnaissance mission. With JSpy, you can save time and increase your chances of finding vulnerabilities in your target domains.

## 🚀 Features:

* Extracts headers and response bodies
* Extracts script endpoints and downloads scripts
* Extracts relative URLs from scripts
* Runs nmap scans on each domain

## :book: Requirements

* curl 
* awk 
* bash 
* grep 
* find 
* rmdir 
* tee 
* nmap 
* Ruby  (and the extract.rb script located in /root/Tool/relative-url-extractor/)

## :gear: How SETUP IT 
1. Create a file named scope.txt that contains the target domain:
```bash 
┌──(root㉿kali)-[~/path/to/directory]
└─# cat scope.txt
example.com
````
2. Create a directory in the root user named Tools and download relative-url-extractor in it:
 ```bash 
┌──(root㉿kali)-[~/path/to/directory]
└─# mkdir /root/Tools/ && cd /root/Tools/ && git clone https://github.com/jobertabma/relative-url-extractor.git
````
4. Create a file named alive.txt that contains the subdomains of your target in URL form:
````bash
┌──(root㉿kali)-[~/path/to/directory]
└─# cat alive.txt 
https://subdomain1.example.com
https://subdomain2.example.com
http://subdomain3.example.com
````
5. Create a folder named after the target domain in `JSpy` directory:
````bash
┌──(root㉿kali)-[~/path/to/directory]
└─# mkdir example.com
````
6. Move `alive.txt` to the folder that you just created
````bash
┌──(root㉿kali)-[~/path/to/directory]
└─# mv alive.txt /root/kiwi.com/
````
7. You are now ready to run the script:
````bash
┌──(root㉿kali)-[~]
└─# git clone https://github.com/SecuritySphinx/JSpy.git
┌──(root㉿kali)-[~]
└─# cd JSpy
┌──(root㉿kali)-[~/JSpy]
└─# echo kiwi.com > scope.txt
┌──(root㉿kali)-[~/JSpy]
└─# mkdir kiwi.com
┌──(root㉿kali)-[~/JSpy]
└─# mv /root/Target/alive.com /root/JSpy/kiwi.com/
┌──(root㉿kali)-[~/JSpy]
└─# bash jspy.sh scope.txt
````

## 🐕 DataHound
The DataHound script uses command-line options to search for specific input within HTML, JavaScript, Nmap scans, and header files. The script traverses through all the collected data and uses grep to find matching keywords.
````bash
root@ubuntu:~/example.com$ ./search.sh -h
[+]USAGE: ./search.sh  (OPTIONS)
-j (string) - search in javascript files
-x (string) - search in header files
-e (string) - search in  html files
-n (string) - search nmap scans
-h - help
````
> 💡 Move the DataHound.sh script to the JS folder of your target.

### Examples to use  Datahound script
````bash
$ ./search.sh -j "admin"          # search for "admin" in JavaScript files
$ ./search.sh -x "nginx"          # search for "nginx" in header files
$ ./search.sh -e "s3.amazonaws"   # search for "s3.amazonaws" in HTML files
$ ./search.sh -n "ssh"            # search Nmap scans for the string "ssh"
````
<a href="https://www.buymeacoffee.com/SecuritySphinx" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy Me A Coffee" style="height: 41px !important;width: 174px !important;box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;-webkit-box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;" ></a>


