
# Hack, when powershell launches a new process with elevated priviledges the working directory is reset to C:\Windows\System32,
# always, no matter if you tell it to use a specific working directory. So we change the directory based on the input file.
# See https://github.com/microsoft/terminal/issues/7062#issuecomment-664728705 
# "For those applications, the start-in folder specified by the shortcut is ignored in favor of C:\Windows\System32. The ignorance is deliberate ..."
cd ($myinvocation.mycommand.definition).substring(0,($myinvocation.mycommand.definition).lastindexof("\"))


# Relaunches the powershell process as administrator if not admin
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))  
{  
  Start-Process powershell -Verb runAs -ArgumentList $myinvocation.mycommand.definition
  Break
}

# Script removes the old DVD drive and remounts the iso in a new DVD drive before restarting the VM
# Script must be run as administrator
# The script assumes there is already a gen1 Hyper-V VM named mukube setup to boot from CD. 

Stop-VM -VMName mukube -Force

Get-VMDvdDrive -VMName mukube | Remove-VMDvdDrive 

Add-VMDvdDrive -VMName mukube -Path .\output\rootfs.iso

Start-VM -Name mukube

