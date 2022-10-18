#!/bin/bash
# fsi - Fetch System Information - a minimalist command-line system information fetching tool.
# Copyright (c) 2022 kiril-u
# https://github.com/kiril-u/fetch-system-information
# fsi is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# sysinfo is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with sysinfo. If not, see <https://www.gnu.org/licenses/>.
version=0.01
# ------------------- VARIABLES: -------------------
datetime="[$(date +"%Y-%m-%d %H:%M")] "
# ------------------- SOFTWARE: -------------------
function os { cat /etc/*-release | grep "PRETTY_NAME" | cut -d "\"" -f2; } # Operating System

function userhost { printf "$(tput setaf 2)$(logname)$(tput sgr0)$(tput setaf 4)@$(tput sgr0)$(tput setaf 6)$(tput bold)$(hostname)$(tput sgr0)"; } #user[at]hostname

function kernel { awk '/Linux/ {print $1 " " $3;}' /proc/version; } # Kernel version

function your_shell {
	local users_shell=$(echo $SHELL | cut -d "/" -f3)
	case $users_shell in
		bash) echo "$users_shell $(echo $BASH_VERSION | cut -d '(' -f1)" ;;
		tcsh) echo "$users_shell $version" ;;
		zsh) echo "$users_shell $ZSH_VERSION" ;;
		ksh) echo "$users_shell $KSH_VERSION" ;;
		fish) echo "$users_shell $version" ;;
		*) showSHELL=false ;;
	esac
} # outouts users shell and shell version

function terminal { printf $TERM | cut -d "-" -f2; } # Displays the name of your terminal emulator

function package_manager {
	declare -A osInfo;
	osInfo[/etc/redhat-release]=yum
	osInfo[/etc/arch-release]=pacman
	osInfo[/etc/gentoo-release]=emerge
	osInfo[/etc/SuSE-release]=zypp
	osInfo[/etc/debian_version]=apt-get
	for f in ${!osInfo[@]}
	do
    	if [[ -f $f ]];then
    		pkg_manager=${osInfo[$f]}
        	printf "${osInfo[$f]}"
    	fi
	done
}

function numpackages { # Count now many packages are currently installed on your system.
	
	declare -A osInfo;
	osInfo[/etc/redhat-release]=yum
	osInfo[/etc/arch-release]=pacman
	osInfo[/etc/gentoo-release]=emerge
	osInfo[/etc/SuSE-release]=zypp
	osInfo[/etc/debian_version]=apt
	for f in ${!osInfo[@]}
	do
    	if [[ -f $f ]];then
    		pkg_manager="${osInfo[$f]}"
        	# printf "${osInfo[$f]}"
    	fi
	done

	if [[ "$(dpkg-query -s apt | grep "^Status" | cut -d : -f 2)" == " install ok installed" ]]; then
		echo -n "$(dpkg-query -f '${binary:Package}\n' -W | wc -l) ($pkg_manager)"; fi
	if [[ "$(dpkg-query -s flatpak | grep "^Status" | cut -d : -f 2)" == " install ok installed" ]]; then
		echo -n ", $(expr $(flatpak list | wc --lines) - 1) (flatpak)"; fi
	if [[ "$(dpkg-query -s snapd | grep "^Status" | cut -d : -f 2)" == " install ok installed" ]]; then
		echo -n ", $(expr $(snap list | wc --lines) - 1) (snap)"; fi
	echo "."
}

function up_time { uptime -p | awk '{print $2 " " $3 " " $4 " " $5 " " $6 " " $7;}'; } # Displays up time. This one may be buggy because I haven't tested it on a machine that was on for more than a day.

function de { echo -n "${XDG_CURRENT_DESKTOP} ${XDG_SESSION_DESKTOP^}"; }

function editor { printf "${VISUAL:-$EDITOR}"; }

# ------------------- HARDWARE: -------------------

function cpu { local cpu_name=$(cat /proc/cpuinfo | grep "model name" -m 1 | cut -d ":" -f2); echo -ne "$cpu_name "; } # CPU model

function cpu_cores { local num_cores=$(cat /proc/cpuinfo | cat /proc/cpuinfo | grep "cpu cores" -m 1  | cut -d ":" -f2); echo -ne "$num_cores"; } # Number of cores

function cpu_temp { sensors | awk '/^CPU:/ {print $2}'; } # CPU temperature
# function cpu_usage { printf "$(ps -A -o pcpu | tail -n+2 | paste -sd+ | bc)%%"; } # shows CPU usage by percentage

function battery { upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep -E "state|to\ full|percentage"; } # Shows battery's state and how charged it is
function battery_alt { if test -f "/sys/class/power_supply/BAT0"; then
        printf "BAT: $(cat /sys/class/power_supply/BAT0/capacity)%%"
else
        printf "AC"
fi; }
function graphics {
echo -n $(glxinfo -B | grep "OpenGL renderer string" | cut -d ":" -f2); }
# local GPU="$(lspci | grep VGA | cut -d ":" -f3) $(lspci| grep "Display controller" | cut -d ":" -f5)"; }
# function gpu {
# GPU=$(lspci | grep VGA | cut -d ":" -f3);RAM=$(cardid=$(lspci | grep VGA |cut -d " " -f1);lspci -v -s $cardid | grep " prefetchable"| cut -d "=" -f2); echo $GPU $RAM; } # GPU info
function display_resolution { xdpyinfo | awk '/dimensions/ {print $2}'; } # Current display resolution
function ram {
free --mega | awk '/^Mem:/ {print $3 " MB/" $2 " MB"}'; } # Shows memory used/total memory
function ram_percentage { echo -n "($(awk '/^Mem/ {printf("%u%%", 100*$3/$2)}' <(free -m))%)"; }
function storage { df -h --total | awk '/^total/ {print $3 "B/" $2 "B" }'; } # Shows storage used / total storage
function displaymngr { cat /etc/X11/default-display-manager | cut -d '/' -f4; }

# ------------------- PROCESSES: -------------------
function proc_mem { ps axch -o cmd:15,%mem --sort=-%mem | head; } # Shows X most memory intensive processes
function proc_cpu { ps axch -o cmd:15,%cpu --sort=-%cpu | head; } # Shows X most cpu intensive processes
# PRINT Temporary (Testing previous functions)

function fulloutput {
printf "\n" && echo "$(tput setaf 2)------------------------$(tput sgr0)" && userhost && printf "\n" && echo "$(tput setaf 2)------------------------$(tput sgr0)"
printf "$(tput setaf 2)OS: $(tput sgr0)" && os
printf "$(tput setaf 2)Kernel: $(tput sgr0)" && kernel
printf "$(tput setaf 2)Uptime: $(tput sgr0)" && up_time
printf "$(tput setaf 2)Packages: $(tput sgr0)" && numpackages
printf "$(tput setaf 2)Shell: $(tput sgr0)" && your_shell
printf "$(tput setaf 2)Terminal: $(tput sgr0)" && terminal
printf "$(tput setaf 2)DE: $(tput sgr0)" && de && printf "\n"
printf "$(tput setaf 2)CPU: $(tput sgr0)" && cpu && printf "," && cpu_cores && printf " cores\n"
# printf "$(tput setaf 2)CPU Temp: $(tput sgr0)" && cpu_temp
printf "$(tput setaf 2)Resolution: $(tput sgr0)" && display_resolution
printf "$(tput setaf 2)GPU: $(tput sgr0)" && graphics && printf "\n"
printf "$(tput setaf 2)Memory: $(tput sgr0)" && ram
printf "$(tput setaf 2)Storage: $(tput sgr0)" && storage
printf "$(tput setaf 2)Power: $(tput sgr0) " && battery_alt && printf " \n" && battery
echo "$(tput setaf 2)------------------------$(tput sgr0)"
echo "$(tput setaf 2)Top 10 processes sorted by memory usage:$(tput sgr0)" && proc_mem
echo "$(tput setaf 2)------------------------$(tput sgr0)"
echo "$(tput setaf 2)Top 10 processes sorted by CPU usage:$(tput sgr0)" && proc_cpu
}
# ------------------- HELP: --------------------
function helpoutput {
echo "fsi - Fetch System Information $version"
echo "kiril-u (c) 2022 under GPLv3"
echo ""
echo "OPTIONS"
echo "    -a,all"
echo "        Print all available columns."
echo "    -h,help"
echo "        Display help text and exit."
echo ""
echo "More options are under development."
exit 0
}
# ------------------- FLAGS: -------------------
while getopts 'ah' OPTION; do
  case "$OPTION" in
    a)
      fulloutput
      ;;
    h)
      helpoutput
      ;;
    ?)
      echo "script usage: fsi [-a] [-h]" >&2
      exit 1
      ;;
  esac
done
shift "$(($OPTIND -1))"
