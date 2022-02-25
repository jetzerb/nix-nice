# fix-docker-machine-time-sync.ps1
$vm = Get-VM -Name DockerDesktopVM
$feature = "Time Synchronization"

Disable-VMIntegrationService -vm $vm -Name $feature
Enable-VMIntegrationService -vm $vm -Name $feature

