#!/bin/bash

################################################
# file name: download.sh
# version: 1.0
# author: Shlomi Ben-David
# email: shlomi.ben.david@gmail.com
# creation date: 18/02/2016
################################################

# EXIT STATUS:
# 0 - the download completed successfully
# 1 - one of the applications is not installed
# 2 - failed to get the file size (broken link)


function show_usage {

	echo "Usage: downloader [OPTION]... URL"
	echo "Download file and show its progress"

	echo -e "\nOPTIONS:"
	echo -e "-s, --save-to PATH\t\tother PATH to where to save the downloaded file" 
	echo -e "\t\t\t\t(default: saves it in the current location)"
	echo -e "-o, --output NAME\t\tnew NAME for the downloaded file"
	echo -e "-h, --help\t\t\tshow this help"

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
	if [[ ${NAME:-"NONE"} != "NONE" ]] ; then
		FNAME="${NAME}"
		WGET_PARAMS+=" -O ${LOCATION}/${NAME}"
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
			exit 1
		fi	
	done
}

function get_file_size {

	INFO_FILE="downloader.info"
	
	# check if file exist
	wget ${URL} --spider &> ${INFO_FILE}

	if ! grep "Length" ${INFO_FILE} ; then 
		echo "failed to get file size" &>> ${LOG}
		exit 2
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
		[[ ${CURRENT_SIZE} -eq ${TOTAL_SIZE} ]] && echo "# Done :-)"
	done
	) | zenity --title="${TITLE}" --text="${TEXT}" --percentage=0 --progress
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
					NAME=${2}
					echo "output file name: ${NAME}" &>> ${LOG}
					shift 2
					;;
		-h | --help	)	
					show_usage
					;;

		* 			) 
					URL=${1}
					echo "url: ${URL}" &>> ${LOG}

					# if file starts with (-) show usage and exit
					[[ ${URL} == -* ]] && show_usage || shift 
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



