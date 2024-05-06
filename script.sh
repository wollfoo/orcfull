#!/bin/bash

# Define constants
$XMrigVersion = '6.21.0'
$VmNrHugepages = 1280
$WorkDir = '/usr/share/work'

# Define functions
function Update-System {
	# Update system and set vm.nr_hugepages
	sudo apt-get update
	sudo sysctl -w vm.nr_hugepages=$VmNrHugepages
	sudo bash -c "echo vm.nr_hugepages=$VmNrHugepages >> /etc/sysctl.conf"
}

function Install-Packages {
	# Install necessary packages
	param ($GpuType)
	$packages = @('git', 'wget', 'screen')

	if ($GpuType -eq 'cuda') {
		$packages += 'nvidia-cuda-toolkit'
	} elseif ($GpuType -eq 'opencl') {
		$packages += 'ocl-icd-opencl-dev'
	}

	sudo apt-get install -y $packages
}

function Setup-Directories {
	# Set up directories
	sudo mkdir -p $WorkDir
	Write-Output $WorkDir
}

function Download-And-Extract-Xmrig {
	# Download and extract xmrig
	param ($Version, $WorkDir)
	$tarUrl = "https://github.com/xmrig/xmrig/releases/download/v$Version/xmrig-$Version-linux-x64.tar.gz"
	$tarFile = "xmrig-$Version-linux-x64.tar.gz"
	$downloadPath = "$WorkDir/$tarFile"

	wget -O $downloadPath $tarUrl
	tar -xzvf $downloadPath -C $WorkDir

	$xmrigDir = "$WorkDir/xmrig-$Version"
	$xmrigPath = "$xmrigDir/xmrig"
	$renamedPath = "$xmrigDir/xmrig_renamed"

	sudo mv $xmrigPath $renamedPath
	Write-Output $renamedPath
}

function Detect-Gpu {
	# Detect GPU compatibility (CUDA or OpenCL)
	if (Get-Command nvidia-smi -ErrorAction SilentlyContinue) {
		Write-Output 'cuda'
	} else {
		Write-Output 'opencl'
	}
}

function Start-Xmrig {
	# Start xmrig
	param ($Pool, $Username, $WorkDir, $GpuType)
	$donateLevel = 1
	$algo = 'rx/0'
	$xmrigPath = Download-And-Extract-Xmrig $XMrigVersion $WorkDir

	$cmd = @($xmrigPath, '--donate-level', $donateLevel, '-o', $Pool, '-u', "${Username}.ws-p x", '-a', $algo, '-k', '--tls')

	if ($GpuType -eq 'cuda') {
		$cmd += '--cuda'  # Use NVIDIA CUDA for GPU mining
	} elseif ($GpuType -eq 'opencl') {
		$cmd += '--opencl'  # Use OpenCL for GPU mining
	}

	sudo $cmd
}

# Main script
Update-System
$gpuType = Detect-Gpu
Install-Packages $gpuType
$workDir = Setup-Directories

$pool = 'us-zephyr.miningocean.org:5432'
$username = 'ZEPHsAMyUCyAY1HthizFxwSyZhMXhpomE7VAsn6wyuVRLDhxBNTjMAoZdHc8j2yjXoScPumfZNjGePHVwVujQiZHjJangKYWriB'

Start-Xmrig $pool $username $workDir $gpuType
