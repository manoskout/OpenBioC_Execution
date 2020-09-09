#!/bin/bash
# filename: install.sh
# author: @koutoulakis

# This bashscript work only on debian based distros
#
# This script will:
# 1. Check all client dependencies
#	- docker
#	- docker-compose
# 2. Generate unique Executor_Id
#	- user should select what execution environment prefer 
# 3. Customize variables for OpenBioC server

showHelp() {
# `cat << EOF` This means that cat should stop reading when EOF is detected
cat << EOF  
Usage: ./install
Install OpenBio Execution Environment

-h, -help,  --help                  		Display help

-n, -name,  --name                  		Set the name of the execution environment

-e, -exec, 	--execution-engine 				Specify the execution engine (available airflow, cwl-airflow)

-p, -ports, --ports                			Specify the ports that the Execution Environment run. 
(
	1. Workflow Management System Port
	2. Obc API Port
	3. Database Port
	4. Resource Monitoring Port
)


EOF
# EOF is found above and hence cat command stops reading. This is equivalent to echo but much neater when printing out.
}


# $@ is all command line parameters passed to the script.
# -o is for short options like -v
# -l is for long options with double dash like --version
# the comma separates different long options
# -a is for long options with single dash like -version
options=$(getopt -l "help,exec:,ports:," -o "he:p:" -a -- "$@")

# set --:
# If no arguments follow this option, then the positional parameters are unset. Otherwise, the positional parameters 
# are set to the arguments, even if some of them begin with a ‘-’.
eval set -- "$options"

while true
do
case $1 in
-h|--help) 
    showHelp
    exit 0
    ;;
-e|--exec) 
    shift
    export WMS=$1
    ;;
-p|--ports)
    export OBC_WMS_PORT=$2
    export OBC_EXECUTOR_PORT=$4
    export EXECUTOR_DB_PORT=$5
    export NETDATA_MONITORING_PORT=$6
    ;;
--)
    
    break;;
esac
shift
done

# Check if docker exist in your environment

#SETTING COLORS FOR OUTPUTS
WHITE='\e[97m'
RED='\033[0;31m'
NC='\033[0m' # No Color
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
LGREEN='\033[1;32m'

export DISTRO_ID=$(lsb_release -i -s)

echo "Welcome to the OpenBio Executor, ${USER}!"
echo "Installation will take a few minutes. Please be patient..."

echo -e "[${YELLOW}-${NC}] State 1/3 (Check docker) "

# Save the distroID to optimize the installation of docker
echo -e "[${YELLOW}-${NC}] Check if docker already exists..."
# 1> /dev/null 2>&1 not show the output
docker -v 1> /dev/null 2>&1
if [ $? -ne 0 ] ; then 
	echo -e "[${RED}-${NC}] DOCKER IS NOT INSTALLED, please install docker before your Execution Environment installation."
	# Save the distroID to optimize the installation of docker
	echo -e "${WHITE}***You could use the commands below to install the Docker Engine***${NC}\n${YELLOW}
	$ sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 7EA0A9C3F273FCD8
	$ sudo apt-get update
	$ curl -fsSL https://get.docker.com -o get-docker.sh
	$ sudo sh get-docker.sh
	${NC}
	"
	
fi

echo -e "[${YELLOW}-${NC}] State 2/3 (Check docker-compose) "

echo -e "[${YELLOW}-${NC}] Check if docker already exists..."
docker-compose -v
if [ $? -ne 0 ] ; then
	echo -e "[${YELLOW}-${NC}] Docker-Compose is not installed, please install docker-compose before your Execution Environment installation."
	echo -e "${WHITE}***You could use the commands below to install the Docker Engine***${NC}\n${YELLOW}
	$ sudo curl -L \"https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose
	$sudo chmod +x /usr/local/bin/docker-compose
	${NC}
	"	
fi

echo -e "[${YELLOW}-${NC}] State 3/3 (Setting up variables and installing the OpenBio Executor) "

# Select which of the Workflow management system will be used
# wms = workflowmanagement system
# WMS_LIST=(cwl-airflow airflow)
# echo -e "[${LGREEN}-->${NC}] Select one of the following Workflow Management Systems: "
# select option in ${WMS_LIST[@]}; do
# 	if [ 1 -le "$REPLY" ] && [ "$REPLY" -le ${#WMS_LIST[@]} ]; then
# 		echo -e "[${LGREEN}-${NC}] You have chosen $option"
# 		export WMS=$option
# 		break
# 	else
# 		echo -e "[${RED}-${NC}] Wrong selection: Select any number from 1 - ${#WMS_LIST[@]}"
# 	fi
# done
# Set user input for executor name, if the input is empty take default value ("main")
# echo -e "[${YELLOW}-->${NC}] Enter your executor name:" 
# read -e EXECUTOR_INSTANCE
# if [ -z $EXECUTOR_INSTANCE ]; then 
# 	export EXECUTOR_INSTANCE="main"
# 	echo -e "[${YELLOW}-${NC}] Executor name is unset, take default value: main"; 
# else 
# 	echo -e "[${YELLOW}-${NC}] Executor name is set : '$EXECUTOR_INSTANCE'"; 
# fi

#  Create a unique string as a executor name
export EXECUTOR_INSTANCE=$(cat /dev/urandom | tr -dc 'a-z' | fold -w 6 | head -n 1)
# Set OBC_EXECUTOR PATH
export OBC_EXECUTOR_PATH="/home/${USER}/obc_executor_${EXECUTOR_INSTANCE}"

echo "[${YELLOW}-${NC}] Set your installation path for your environment: ${OBC_EXECUTOR_PATH}" 
mkdir -p ${OBC_EXECUTOR_PATH}
export OBC_USER_ID=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

export NETDATA_ID=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)



echo -e "[${YELLOW}-${NC}] Client ID for OpenBioC Server : \033[38;2;0;255;0m${OBC_USER_ID}\033[0m"
export PUBLIC_IP=$(curl http://ip4.me 2>/dev/null | sed -e 's#<[^>]*>##g' | grep '^[0-9]')

# File contains images
wget -O ${OBC_EXECUTOR_PATH}/docker-compose.yml https://raw.githubusercontent.com/manoskout/OpenBioC_Execution/master/docker-compose-${WMS}.yml
# Config File only for airflow
if [[ "$WMS" == *"airflow"* ]]; then
	wget -O ${OBC_EXECUTOR_PATH}/airflow.cfg https://raw.githubusercontent.com/manoskout/OpenBioC_Execution/master/airflow.cfg
fi


# Set obc_executor_run.sh (Optional)
# wget https://raw.githubusercontent.com/manoskout/docker-airflow/master/obc_executor_run.sh
echo -e "[${YELLOW}-${NC}] Running Directory : $(pwd)"

# Check if the pre-defined ports are in use 
# export OBC_AIRFLOW_PORT=8080
# export OBC_EXECUTOR_PORT=5000
# export EXECUTOR_DB_PORT=5432
# export NETDATA_MONITORING_PORT=19998

# Check port that service could starts running
function portfinder (){
	netstat -pant /dev/null 2>&1 | grep $1  > /dev/null 2>&1 
	while [ $? -eq 0 ] ;
	do
		echo "Port -- $1 -- is already in use..."
		set -- $(expr $1 + 1) $1
		netstat -pant /dev/null 2>&1 | grep $1  > /dev/null 2>&1
	done
	echo "$1"
}
# Environment variables that used from Executor
cat >> ${OBC_EXECUTOR_PATH}/.env << EOF
EXECUTOR_INSTANCE=${EXECUTOR_INSTANCE}
POSTGRES_USER=airflow
POSTGRES_PASSWORD=airflow
POSTGRES_DB=airflow
OBC_USER_ID=${OBC_USER_ID}
PUBLIC_IP=${PUBLIC_IP}
OBC_EXECUTOR_PORT=$(portfinder $OBC_EXECUTOR_PORT)
OBC_WMS_PORT=$(portfinder $OBC_WMS_PORT)
NETDATA_MONITORING_PORT=$(portfinder $NETDATA_MONITORING_PORT)
EXECUTOR_DB_PORT=$(portfinder $EXECUTOR_DB_PORT)
NETDATA_ID=${NETDATA_ID}
WORKFLOW_FORMAT=${WMS}
EOF

#TODO -> change using docker-compose up -f asfsedfsdf.yml(FAILED)
cd ${OBC_EXECUTOR_PATH}
docker-compose up -d

if [ $? -eq 0 ] ; then 

	export OBC_EXECUTOR_URL="http://${PUBLIC_IP}:${OBC_EXECUTOR_PORT}/${OBC_USER_ID}"
	export NETDATA_URL="http://${PUBLIC_IP}:${NETDATA_MONITORING_PORT}/${NETDATA_ID}"
	echo -e "${GREEN}\n\n\n Successful installation \n\n\nClose tests ....\n\n${NC}"
    docker-compose down
	echo -e "${YELLOW}**IMPORTANT**${NC}"
	echo -e "${GREEN}\n\t Add the link below to your profile page in openbio.eu. For more info see: https://github.com/kantale/OpenBioC/tree/master/Documentation#installation \n${NC}"
	echo -e "${LGREEN}${OBC_EXECUTOR_URL}${NC}"
	echo -e "${GREEN}\n\tNetdata url: (Use this URL anytime to check the resources of the execution environment) \n${NETDATA_URL}${NC}"

	echo -e "${YELLOW}***IMPORTANT***${NC}\n${YELLOW}
	1)Before being able to run workflows you need to start the execution environment with the following commands:${NC}
		$ cd ${OBC_EXECUTOR_PATH}
		$ docker-compose up \n
	2)To stop the execution environment run:
		$ cd ${OBC_EXECUTOR_PATH}
		$ docker-compose down
	${NC}
	"
else
	echo "docker-compose is not running. Check if docker is installed and that you have the right privileges to run it."
	docker-compose down
fi
