#!/bin/bash

################################################
# file name: download.sh
# author: Shlomi Ben-David
# email: shlomi.ben.david@gmail.com
# creation date: 18/02/2016
################################################

# get file size (from: user/web/local)
# download the file
# check file size status


function show_usage {

	echo "Usage: downloader [OPTION]... FILE"
	echo -e "Download file and show its progress\n"

	echo "OPTIONS:"
	echo "-l, --location URL|PATH		file location"
	echo "-s, --size SIZE			file size"

	exit 0
}

function start_downloader {
	
	TITLE="Downloader"
	TEXT="Downloading ${FILE}, please wait..."

	zenity --title="${TITLE}" --text="${TEXT}" --percentage=0 --auto-close --progress

}

##############
#### MAIN ####
##############

log="/var/log/download.log"

[ $# -eq 0 ] && show_usage

echo "\$@=$@" >> ${log}

while [ $# -gt 0 ]
do
	key=${1}

	case ${key} in

		-s | --size 		) 
					SIZE=${2}
					echo "file size: ${SIZE}"
					shift 2
					;;
		-l | --location 	)
					LOCATION=${2}
					echo file location: ${LOCATION}
					shift 2
					;;
		* 			) 
					FILE=${1}
					shift 
					# if file starts with (-) show usage and exit
					[[ ${FILE} == -* ]] && show_usage || echo "file name: ${FILE}"
					;;
	esac		
done
