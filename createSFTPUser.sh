#!/bin/bash

########################################################################
#                                                                      #
#       ,                                                              #
#   /\^/`\                                                             #
#  | \/   |  Description : Script for creating SFTP Users              #
#  | |    |  Author : Laxman Singh <laxman.nrlm@gmail.com>        jgs  #
#  \ \    /  Created On : 10 Feb, 2016                          _ _    #
#   '\\//'                                                    _{ ' }_  #
#     ||                                                     { `.!.` } #
#     ||                                                     ',_/Y\_,' #
#     ||  ,                                                    {_,_}   #
# |\  ||  |\                                                     |     #
# | | ||  | |                                                  (\|  /) #
# | | || / /                                                    \| //  #
#  \ \||/ /                                                      |//   #
#   `\\//`   \   \./    \\   \./    \\   \./    \\   \./    \ \\ |/ /  #
#  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #
#                                                                      #
########################################################################

RED='\033[0;31m'
GREEN='\033[32m'
ORANGE='\033[33m'
BLUE='\033[34m'
NC='\033[0m'

PASS_REGEX='0-9a-zA-Z $%&#@!'


function main() {

	echo -e "\n"
	echo -e "Welcome to SFTP USER CREATION PROGRAM\nCreates SFTP Users in CHROOT JAIL Environment\n" 
	echo -e "\n"
	while true; do
		read -p "Are You sure want to create SFTP USER? Y/N:    " input
		case $input in
			[Yy]* ) createUser; break;;
			[Nn]* ) echo -e "${BLUE}Thanks....... (^_^)${NC}"; exit;;
			* ) echo -e "${RED}Invalid Input. Please answer Yes or No.${NC}";;
		esac
	done
}

function createUser () {

	while true; do
		echo -e "1.) Press 1 for creating a new SFTP User\n2.) Press q for exiting the program.\n"
		read -p " : " input
		case $input in
			1 ) createSFTPUser; break;;
			[Qq]* ) exit;;
			* ) echo -e "${RED}Invalid Input.${NC}\n";;
		esac
		
	done	
}

function createSFTPUser() {

	# ask for SFTP User Name
	read -p "Enter SFTP User Name : " userName
	#validate input
	while [[ "$userName" != *[[:alpha:]*] ]]; do
		echo -e "${RED}Invalid User Name (only Alphabates allowed)${NC}\n"                
                read -p "Enter SFTP User Name : " userName		
	done
	
	## check if user already exists
	USER_CHECK=$(grep -c ^$userName: /etc/passwd)
	while [[ $USER_CHECK != 0 ]]; do
		echo -e "${RED}User ($userName) already exists.${NC}\n"
		read -p "Enter SFTP User Name : " userName
		USER_CHECK=$(grep -c ^$userName: /etc/passwd)
	done
	
	# ask for password
	echo -e "\nEnter Password\n${ORANGE}Note: Password should be at least 6 characters long with one digit and one Upper case Alphabet and one special charector containing (#@!*)${NC}\n"
	#read -sp ": " pass1
	prompt=": "
	while IFS= read -p "$prompt" -r -s -n 1 char
	do
    	if [[ $char == $'\0' ]]
    	then
        	break
    	fi
    		prompt='*'
    		pass1+="$char"
	done
	echo

	#validate it
	while [[ ! $pass1 =~ ^[A-Za-z0-9#@!*]{6,20}$ ]]; do
		echo -e "${RED}Invalid Password (Password should be at least 6 characters long with one digit and one Upper case Alphabet and one special charector containing (#@!*))${NC}\n"
		pass1=
		prompt=": "
		while IFS= read -p "$prompt" -r -s -n 1 char
        	do
        	if [[ $char == $'\0' ]]
        	then
                	break
        	fi
        		prompt='*'
                	pass1+="$char"
        	done
		echo
	done
	
	# re-enter password
	prompt=": "
	echo -e "\nRe-Enter Password\n"
	#read -sp ": " pass2
	while IFS= read -p "$prompt" -r -s -n 1 char
        do
                if [[ $char == $'\0' ]]
        then
                break
        fi
                prompt='*'
                pass2+="$char"
        done
	echo

	# check both passwords matches
	while [[ $pass1 != $pass2 ]]; do
                echo -e "${RED}Password mismatched.${NC}\n"
		prompt=": "
		pass2=
		while IFS= read -p "$prompt" -r -s -n 1 char
        	do
                	if [[ $char == $'\0' ]]
        	then
                	break
        	fi
               		prompt='*'
                	pass2+="$char"
        	done
		echo
        done

	## information collected from user now do the SSH configuration for CHROOT JAIL ENVIRONMENT
	
	## notify user about user creation
	echo -e "${ORANGE}Below SFTP User will be created:${NC}\n"
	echo -e "${BLUE}SFTP User:\t" $userName "${NC}\n=========================================================="

	## ask for confirmation
	read -p "Proceed Next to User Creation? Y/N :" con
	case $con in
		[Yy]* ) doFinalSFTPConfiguration $userName $pass1; break;;
                [Nn]* ) echo -e "${BLUE}Thanks....... (^_^)${NC}"; exit;;
                * ) echo "${RED}Invalid Input. Please answer Yes or No.${NC}";;
        esac
}

function doFinalSFTPConfiguration() {

	USERNAME=$1
	PASSWD=$2
	encryptedPasswd=$(perl -e 'print crypt($ARGV[0], "salt")' $PASSWD)
	
	echo -e "${ORANGE}Adding User ...${NC}\n"
        useradd -g sftpusers -d /$USERNAME -s /sbin/nologin -p $encryptedPasswd $USERNAME > /tmp/output 2>&1
	STATUS_FLAG=$?

	echo -ne '#####                     (23%)\r'
	sleep 1
	echo -ne '#########                 (46%)\r'
	if [[ $STATUS_FLAG -eq 0 ]]; then
		sleep 1
		echo -ne '#############             (60%)\r'
		#echo -ne '\n'
	else
		echo -e "\n"
		echo -e "${RED}User ($USERNAME) Creation Failed...!!\n$(cat /tmp/output)${NC}"
		exit
	fi

	# do rest of work
	mkdir -p /opt/sftp/$USERNAME/$USERNAME
	sleep 1
        echo -ne '###############             (69%)\r'

	chown root:sftpusers /opt/sftp/$USERNAME
	sleep 1
        echo -ne '##############             (78%)\r'

	sleep 1
        echo -ne '##################         (80%)\r'

	sleep 1
        echo -ne '######################     (88%)\r'

	sleep 1
        echo -ne '#########################  (92%)\r'

	sleep 1
	chown -R $USERNAME:sftpusers /opt/sftp/$USERNAME/$USERNAME

	if [[ $? -eq 0 ]]; then
                echo -ne '######################################  (100%)\r'
		echo -e "\n"
        else
		echo -e "\n"
                echo -e "${RED}User ($USERNAME) Creation Failed...!! ${NC}"
                exit
        fi
	
        ## notify user
        echo -e "${ORANGE}User Created.${NC}"
	echo -e "${GREEN}"
	echo -e "User Name:Home Directory\n$USERNAME:/opt/sftp/$USERNAME/$USERNAME\n" | column -t -s ':'
	echo -e "${NC}\n\n"
	createUser	

}

# execute main method
clear
main
