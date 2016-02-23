#!/bin/bash

################################################
# file name: download.sh
# version: 1.0
# author: Shlomi Ben-David
# email: shlomi.ben.david@gmail.com
# creation date: 18/02/2016
################################################

# TODO:
# show usage 					- completed
# check environment:
#	apps installed				- completed
#	
# get file size (from: user/web/local)
# download the file
# check file size status
	
# EXIT STATUS:
# 0 - the download completed successfully
# 2 - one of the applications is not installed
# 3 - failed to get the file size (broken url)


function show_usage {

	echo "Usage: downloader [OPTION]... URL"
	echo "Download file and show its progress"

	echo -e "\nOPTIONS:"
	echo -e "-s, --save-to PATH\t\tsave file to PATH"
	echo -e "-o, --output NAME\t\tsave file as NAME"

	exit 0
}

function check_parameters {

	WGET_PARAMS="-b -c"

	# if we received different location to save the file
	if [[ ${LOCATION:-"NONE"} != "NONE" ]] ; then

		# check if location ends with (/)
		[[ ${LOCATION} == */ ]] && LOCATION=$(echo ${LOCATION::-1})
		
		WGET_PARAMS+=" -P ${LOCATION}"
	else
		LOCATION="."
	fi

	# if we received different name for the saved file 
	if [[ ${FILE:-"NONE"} != "NONE" ]] ; then
		FNAME="${FILE}"
		WGET_PARAMS+=" -O ${LOCATION}/${FILE}"
	else
		FNAME=`basename ${URL}` 
	fi

	echo "wget parameters: ${WGET_PARAMS}" &>> ${LOG}
}

function check_environment {

	APPS="wget zenity"

	for app in ${APPS}
	do
		if ! yum list installed ${app} &> /dev/null ; then
			echo "'${app}' is not installed!" &>> ${LOG}
			exit 2
		fi	
	done
}

function get_file_size {

	INFO_FILE="downloader.info"
	
	# check if file exist
	wget ${URL} --spider &> ${INFO_FILE}

	if ! grep "Length" ${INFO_FILE} ; then 
		echo "failed to get file size" &>> ${LOG}
		exit 3
	fi
		
	SIZE=`grep "Length" ${INFO_FILE} | awk '{print $2}'`
	echo "file size=${SIZE}" &>> ${LOG}
}

function start_downloader {
	 
	TITLE="Downloader"
	TEXT="Downloading ${FNAME} file, please wait..." 

	wget ${WGET_PARAMS} ${URL} 
	while [ ! -f ${LOCATION}/${FNAME} ] 
	do
		sleep 1
	done	


	(
	CURRENT_SIZE=`ls -ls ${LOCATION}/${FNAME} | awk '{print $6}'`
	TOTAL_SIZE=${SIZE}	
	while [[ ${CURRENT_SIZE:-0} -lt ${TOTAL_SIZE} ]]
	do
		PERCENT=$(bc -l <<< "scale=2;${CURRENT_SIZE}/${TOTAL_SIZE}*100")
		echo ${PERCENT}
		sleep 1
		
		CURRENT_SIZE=`ls -ls ${LOCATION}/${FNAME} | awk '{print $6}'`
	done
	) | zenity --title="${TITLE}" --text="${TEXT}" --percentage=0 --auto-close --progress
	[[ $? -ne 0 ]] && clear_leftovers 

}

function clear_leftovers {

	rm -f wget-log*
	killall wget
	rm -f ${LOCATION}/${FNAME}
}

trap clear_leftovers SIGHUP SIGKILL SIGINT

##############
#### MAIN ####
##############

LOG="downloader.log"
[ -f ${LOG} ] && rm -f ${LOG}

# if no parameters passed, show usage and exit
[ $# -eq 0 ] && show_usage

echo "params=$@" >> ${LOG}

while [ $# -gt 0 ]
do
	KEY=${1}

	case ${KEY} in

		-s | --save-to 	)
					LOCATION=${2}
					echo "save file location: ${LOCATION}" &>> ${LOG}
					shift 2
					;;
		-o | --output	)
					FILE=${2}
					echo "output file name: ${FILE}" &>> ${LOG}
					shift 2
					;;
		* 			) 
					URL=${1}
					shift

					# if file starts with (-) show usage and exit
					[[ ${URL} == -* ]] && show_usage || echo "url: ${URL}" &>> ${LOG}
					;;
	esac		
done

# check passed parameters
check_parameters

# check the environment
check_environment

# get file size
get_file_size

# start downloader
start_downloader


