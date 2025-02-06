#!/bin/bash

# architectire of operation system and its kernel version
arch=$(uname -srvmo)

# number of physical processors
pcpu=$(grep "physical id" /proc/cpuinfo | uniq | wc --lines)

# number of virtual processors
vcpu=$(grep "processor" /proc/cpuinfo | uniq | wc --lines)

# current available RAM on server and its utilization rate as a percentage
memuse=$(free --mega | awk '$1 == "Mem:" {print $3}')
tot_mem=$(free --mega | awk '$1 == "Mem:" {print $2}')
mem_per=$(free --mega | awk '$1 == "Mem:" {printf("%.2f"), $3/$2*100}')

# current available storage on serwer and its utilization rate as percentage
diskuse=$(df -h --total | grep "/dev/" | grep -v "/boot" | awk '{disk_t += $2} END {printf ("%.1fGb"), disk_t/1024}')
tot_disk=$(df -h --total | grep "/dev/" | grep -v "/boot" | awk '{disk_u += $3} END {print disk_u}')
disk_per=$(df -h --total | grep "/dev/" | grep -v "/boot" | awk '{disk_u += $3} {disk_t += $2} END {printf("%d"), disk_u/disk_t*100}')

# current utilization rate of processors as a percentage
cpu_var1=$(vmstat 1 2 | tail -1 | awk '{printf $15}')
cpu_var2=$(expr 100 - $cpu_var1)
cpuload=$(printf "%.1f" $cpu_var2)

# date and time of the last reboot
lboot=$(who --boot | awk '$1 == "system" {print $3 " " $4}')

# whether LVM is active or not
lvmuse=$(if [ $(lsblk | grep "lvm" | wc --lines) -gt 0 ]; then echo yes; else echo no; fi)

# number of active connections
contcp=$(ss -ta | grep ESTAB | wc --lines)

# number of users using the server
ulog=$(users | wc --words)

# IPv4 address of server and its MAC address
ip=$(hostname -I | awk '{print $1}')
mac=$(ip link | grep "link/ether" | awk '{print $2}')

# number of commands executed with the sudo program
sudo=$(journalctl _COMM=sudo | grep COMMAND | wc --lines)

wall "	Architecture: $arch
		CPU physical : $pcpu
		vCPU : $vcpu
		Memory Usage: $memuse/${tot_mem}MB ($mem_per%)
		Disk Usage: $diskuse/${tot_disk} ($disk_per%)
		CPU load: $cpuload%
		Last boot: $lboot
		LVM use: $lvmuse
		Connections TCP: $contcp ESTABLISHED
		User log: $ulog
		Network: IP $ip ($mac)
		Sudo: $sudo cmd"