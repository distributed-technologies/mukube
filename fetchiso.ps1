
(Test-Path output) -or (mkdir output)
# Note the ip is dynamic and ssh-key is stored elsewhere. This is only useable by me right now. 
scp andreas@13.95.104.95:/home/andreas/mukube/output/rootfs.iso .\output\

