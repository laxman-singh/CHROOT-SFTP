#!/bin/bash
###############################################################################
#                                                                             #
#                                   .-"""-.                                   #
#                                  / .===. \                                  #
#                                 / / a a \ \                                 #
#                                / ( \___/ ) \                                #
#   __________________________ooo\__\_____/__/_____________________________   #
#  /                                                                       \  #
# | Description : Script for deleting SFTP User with their home directories | #
# | Author : Laxman Singh                                                   | #
# | Created On : 12th Feb, 2016                                             | #
#  \__________________________________________ooo__________________________/  #
#                                /           \                                #
#                               /:.:.:.:.:.:.:\                               #
#                                   |  |  |                                   #
#                                   \==|==/                                   #
#                                   /-'Y'-\                                   #
#                                  (__/ \__)                                  #
#                                                                             #
###############################################################################

RED='\033[0;31m'
GREEN='\033[32m'
ORANGE='\033[33m'
BLUE='\033[34m'
NC='\033[0m'


function printUsage() {
	echo -e "${RED}USAGE:\t$0 <USER>\t (e.g. $0 user1)${NC}"; exit 1	
}

function isUserExists() {

	USER_TO_CHECK=$1
	USER_CHECK=$(grep -c ^$USER_TO_CHECK: /etc/passwd)
	return $USER_CHECK
}

function deleteUser() {

	## delete SFTP User
	STATUS=$(userdel -r $UNAME)
	if [[ $? -eq 0 ]]; then
		rm -rf /opt/sftp/$UNAME
		echo -e "${GREEN}SFTP User : \t$UNAME successfully deleted..!!${NC}"
	else
		echo -e "${RED}SFTP User : \t$UNAME not deleted..\nPlease contact your System Admin.${NC}"
	fi	
}

function listSFTPUser() {

	echo -e "${BLUE}"
	echo -e "SFTP User's in This System" 
	echo -e "${NC}"
	echo -e "${GREEN}"
	ls /opt/sftp | cat
	echo -e "${NC}"
}

if [[ $# -eq 0 ]]; then
	printUsage;
fi

#echo -e "\n${ORANGE}SFTP User Deletion Program\n${BLUE}This will delete the SFTP User with thier SFTP CHROOT Directories.${NC}"
	
UNAME=$1
isUserExists $UNAME
#echo "STATUS =  "$?
if [[ $? -eq 0 ]]; then
	echo -e "${RED}SFTP User :\t$UNAME does not exists....!${NC}"
	echo -e "${ORANGE}Do you want to list SFTP User? Y/N :${NC}"
	read -p " : " input
	case $input in 
		[Yy]* ) listSFTPUser; exit 1;;
		[Nn]* ) exit 1;;
		* )  echo -e "${RED}Invalid Input.${NC}\n"; exit 1;;
	esac
else
	if [[ ! -d "/opt/sftp/$UNAME/$UNAME" ]]; then 
		#if [[ $UNAME == "root" ]]; then echo -e "${RED}Ooooooops........ Why are you deleting Admin User(root)?${NC}"; exit 1; fi
		echo -e "${RED}User : \t$UNAME is not a SFTP user. We/You are not authorized to delete this type of User.${NC}"
		exit 1
	fi
fi

echo -e "${ORANGE}All Data related to this SFTP USER will be deleted and it can't be undone. Are you sure want to delete this SFTP User${NC} (${BLUE}$UNAME${NC}${ORANGE}) : Y/N :${NC}"
read -p " : " input
case $input in
	[Yy]* ) deleteUser;;
	[Nn]* ) exit;;
	* ) echo -e "${RED}Invalid Input.${NC}\n";;
esac
