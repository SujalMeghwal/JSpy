# JSpy
This script performs reconnaissance on a list of domains. It creates directories for storing output, extracts headers and response bodies from each domain, extracts script endpoints and downloads scripts, extracts relative URLs from scripts, and runs nmap scans on each domain.

## requirement and How SETUP IT 
1. Make file name `scope.txt` that file contaiin single main domain your tagert
```bash 
┌──(root㉿kali)-[~/path/to/directory]
└─# cat scope.txt
kiwi.com
````
2. Make a directory in root user name it Tools and download relative-url-extractor
 ```bash 
┌──(root㉿kali)-[~/path/to/directory]
└─# mkdir /root/Tool/ && cd /root/Tool/ && git clone https://github.com/jobertabma/relative-url-extractor.git
Cloning into 'relative-url-extractor'...
remote: Enumerating objects: 27, done.
remote: Total 27 (delta 0), reused 0 (delta 0), pack-reused 27
Receiving objects: 100% (27/27), 473.50 KiB | 1.75 MiB/s, done.
Resolving deltas: 100% (11/11), done.
````
3. Make sure you have Bash installed on your system. You can check if Bash is installed by running the following command in your terminal:
```bash 
┌──(root㉿kali)-[~/path/to/directory]
└─# bash --version
````
4. You must have alive.txt which conatain the domain of your tagret also in urls form 
````bash
┌──(root㉿kali)-[~/path/to/directory]
└─# cat alive.txt 
https://abaviaiton.kiwi.com
https://governorsaviation.kiwi.com
http://governorsaviation.kiwi.com
````
5. Make a Folder which name be same as scope.txt domain name : for example i will take `kiwi.com` domain
````bash
┌──(root㉿kali)-[~/path/to/directory]
└─# cat scope.txt
kiwi.com
┌──(root㉿kali)-[~/path/to/directory]
└─# mkdir kiwi.com
````
6. Move alive.txt to kiwi.com Folder
````bash
┌──(root㉿kali)-[~/path/to/directory]
└─# mv alive.txt /root/kiwi.com/
kiwi.com
┌──(root㉿kali)-[~/path/to/directory]
└─# mkdir kiwi.com
````
7.  Make sure you have Nmap installed on your system. You can check if nmap is installed by running that command in your terminal:
````bash
┌──(root㉿kali)-[~/path/to/directory]
└─# nmap --help
Nmap 7.93 ( https://nmap.org )
Usage: nmap [Scan Type(s)] [Options] {target specification}
````
8. Now you are ready to run that script 
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
