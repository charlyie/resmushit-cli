#!/bin/bash
# reSmush.it CLI (Shell client)
# chmod 755 resmushit.sh
# cp resmushit.sh /usr/bin/resmushit
# then run: ./resmushit <filename>
#
# A CLI for reSmush.it, the Image Optimizer API
#
# The MIT License (MIT)
# Copyright (c) 2018 Charles Bourgeaux <hello@resmush.it> and contributors
# You are not obligated to bundle the LICENSE file with your projects as long
# as you leave these references intact in the header comments of your source files.

VERSION="1.0.1"
BUILD_DATE="20180812"
REQUIRED_PACKAGES=( "curl" "jq" )

# System variables
API_URL="http://api.resmush.it"
QUALITY=92
OUTPUT_DIR="."
APP_DIR=$(dirname "$0")
TIME_LOG=true
QUIET_MODE=false
RED="\033[0;31m"
GREEN="\033[0;32m"
LBLUE="\033[0;36m"
NC="\033[0m" # No Color
POSITIONAL=()

# Display output and save it to log file.
cli_output(){
	if [[ $QUIET_MODE == "true" ]];
	then
		return
	fi
	TIME="[`date '+%Y-%m-%d %H:%M:%S'`] "
	COLOR_OPEN_TAG=''
	COLOR_CLOSE_TAG=$NC
	if [[ $2 == "green" ]]; 
	then 
		COLOR_OPEN_TAG=$GREEN
	elif [[ $2 == "red" ]]; 
	then
		COLOR_OPEN_TAG=$RED
	elif [[ $2 == "blue" ]]; 
	then
		COLOR_OPEN_TAG=$LBLUE
	elif [[ $2 == "standard" ]]; 
	then
		COLOR_OPEN_TAG=$NC
	fi
	if [[ $3 == "notime" ]] || [[ $TIME_LOG == false ]]; then
		TIME=""
	fi
	printf "${COLOR_OPEN_TAG}${TIME}$1 ${COLOR_CLOSE_TAG}\n"
}

# Manage arguments
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -q|--quality)
    QUALITY="$2"
    shift # past argument
    shift # past value
    ;;
    -o|--output)
    OUTPUT_DIR="$2"
    shift # past argument
    shift # past value
    ;;
    --notime)
    TIME_LOG=false
    shift # past argument
    ;;
    --quiet)
    QUIET_MODE=true
    shift # past argument
    ;;
    -h|--help)
    shift # past argument
    cli_output "reSmush.it Image Optimizer CLI client v.${VERSION}, a Command Line Interface for reSmush.it, the Image Optimizer API" green notime
	cli_output "(c) reSmush.it - Charles Bourgeaux <hello@resmush.it>\n" green notime
	cli_output "Usage: ./resmushit-cli.sh <filename> [--quality <image quality>] [--output <directory] [--notime]"  blue notime
	cli_output "Allowed file format : JPG, PNG, GIF, BMP, TIFF"  standard notime
	cli_output "Startup:" standard notime
	cli_output "  -h or --help \t\t\t\t\t print this help." standard notime
	cli_output "  -v or --version \t\t\t\t display the version of reSmushit CLI client." standard notime
	cli_output "  -q <quality> or --quality <quality> \t\t specify the quality factor between 0 and 100 (default is 92)." standard notime
	cli_output "  -o <directory> or --output <directory> \t specify an output directory." standard notime
	cli_output "  --notime \t\t\t\t\t avoid display timer in output." standard notime
	cli_output "  --quiet \t\t\t\t\t avoid output display.\n" standard notime
	exit 0
    ;;
    -v|--version)
    shift # past argument
    cli_output "reSmush.it CLI v.${VERSION} (build ${BUILD_DATE})" standard notime
    exit 0
    ;;
    -*)    # unknown option
    cli_output "Invalid option: ${1}. Type --help to show help" red notime
    shift
    exit 0
    ;;
    --*)    # unknown option
    cli_output "Invalid option: ${1}. Type --help to show help" red notime
    shift 
    exit 0
    ;;
    *)    # unknown option
    FILES+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${FILES[@]}" # restore positional parameters



# Check required packages and try to install them
for x in ${REQUIRED_PACKAGES[@]}
do
if ! which $x > /dev/null; 
then
  cli_output "Missing package $x. " red
  echo -e "Try to install it ? (y/n) \c"
  read
  if [[ "$REPLY" == "y" ]]; 
  then
	# Package installation on MacOS platform
	if [ "$(uname)" == "Darwin" ]; 
	then
	    cli_output "Trying to install the package using homebrew..."
	    brew install $x       
	elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; 
	then
		if [[ `id -u` -ne 0 ]]; 
		then
		  cli_output "Package installation needs ROOT privileges. Please log as root or use sudo."
		  exit 0
		fi
		
		if [ -n "$(command -v yum)" ]; 
		then
			sudo yum update
			sudo yum install $x
			if ! which sudo > /dev/null || ! which apt-get > /dev/null; 
			then
		      cli_output "Cannot install package '$x' automatically. Please install it manually."
		      exit 0
		    fi
		elif [ -n "$(command -v apt-get)" ]; 
		then
			sudo apt-get -qq update
			sudo apt-get -y -qq install $x 
			if ! which sudo > /dev/null || ! which apt-get > /dev/null; 
			then
		      cli_output "Cannot install package '$x' automatically. Please install it manually."
		      exit 0
		    fi
		else
			cli_output "Unsupported Linux package manager. Try to install the package $x manually."
			exit 0
		fi
	else
	    cli_output "Unsupported platform. Try to install the package $x manually."
		exit 0
	fi
    
  else
    cli_output "Some package are missing. Try to install them before."
    exit 0
  fi
fi
done

if [ ${#FILES[@]} -eq 0 ]; 
then
	cli_output "No input file specified. Usage: resmushit-cli.sh <filename>" red notime
	exit 0
fi


# On first launch create a configuration, otherwise, read from it
api_test=$(curl --write-out %{http_code} --silent --output /dev/null --connect-timeout 5 ${API_URL})
if [[ "$api_test" == "000" ]]; 
then
	cli_output "reSmush.it API is unreachable"
    exit 0
fi

# Creates an output directory if needed
if [ ! -d "$OUTPUT_DIR" ]; 
then
	cli_output "Output directory ${OUTPUT_DIR} isn't existing. Creating..." blue
	mkdir -p ${OUTPUT_DIR}
fi

cli_output "Initializing images optimization with quality factor : ${QUALITY}%%" blue

for current_file in ${FILES[@]}
do
	# Extract file data
	filename=$(basename -- "$current_file")
	extension="${filename##*.}"
	current_file_lower=$( echo $current_file | tr '[:upper:]' '[:lower:]')
	filename="${filename%.*}"
	output_filename="${filename}-optimized.${extension}"

	# Optimize only authorized extensions
	if [[ $current_file_lower =~ \.(png|jpg|jpeg|gif|bmp|tif|tiff) ]]; 
	then
		cli_output "Sending picture ${current_file} to api..."
		api_output=$(curl -F "files=@${current_file}" --silent ${API_URL}"/?qlty=${QUALITY}")
		api_error=$(echo ${api_output} | jq .error)

		# Check if the API returned an error
		if [[ "$api_error" != 'null' ]]; 
		then
			api_error_long=$(echo ${api_output} | jq -r .error_long)
			cli_output "API responds Error #${api_error} : ${api_error_long}"
			exit 0
		else
			# Display result and download optimized file
			api_percent=$(echo ${api_output} | jq .percent)
			if [[ $api_percent == 0 ]]; 
			then
				cli_output "File already optimized. No downloading necessary" green
			else
				api_src_size=$(echo ${api_output} | jq .src_size | awk '{ split( "B KB MB GB" , v ); s=1; while( $1>1024 ){ $1/=1024; s++ } printf "%.2f%s", $1, v[s] }')
				api_dest_size=$(echo ${api_output} | jq -r .dest_size | awk '{ split( "B KB MB GB" , v ); s=1; while( $1>1024 ){ $1/=1024; s++ } printf "%.2f%s", $1, v[s] }')
				cli_output "File optimized by ${api_percent}%% (from ${api_src_size} to ${api_dest_size}). Retrieving..." green
				api_file_output=$(echo ${api_output} | jq -r .dest)
				curl ${api_file_output} --output ${OUTPUT_DIR}/${output_filename} --silent
				cli_output "File saved as ${output_filename}" green
			fi
		fi
	else
		cli_output "File ${current_file} not an allowed picture format, skipping" blue
	fi
done
cli_output "Optimization completed" green





