
# Ensure that the output folder exists
(Test-Path output) -or (mkdir output)
# Note the ip is dynamic and ssh-key is stored elsewhere. This is only useable by me right now. 
scp andreas@13.95.104.95:/home/andreas/mukube/output/rootfs.iso ./output

# Rerun the VM with the new iso
Start-Process powershell -Verb runAs -ArgumentList $pwd\startVM.ps1
