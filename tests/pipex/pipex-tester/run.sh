#!/bin/bash

NC="\033[0m"
BOLD="\033[1m"
ULINE="\033[4m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
MAGENTA="\033[35m"

fatal_error()
{
	if [ -z "$1" ]
	then
		message="fatal error"
	else
		message="$1"
	fi
	if [ -z "$2" ]
	then
		exit_status=1
	else
		exit_status=$2
	fi
	printf "${RED}$message${NC}\n"
	exit $exit_status
}

pipex_test()
{
	"$@" &
	bg_process=$!
	i=0
	while kill -0 $bg_process > /dev/null 2>&1
	do
		if [ $i -eq 5 ]
		then
			kill $bg_process > /dev/null 2>&1
			break
		fi
		sleep 1
		i=$(($i + 1))
	done
	if [ $i -ge 5 ]
	then
		return 254 # arbitrary number for timeout error
	fi
	wait $bg_process
	status_code=$?
	return $status_code
}

cd "$(dirname "$0")"

printf "+------------------------------------------------------------------------------+\n"
printf "|                                                                              |\n"
printf "|                                                                              |\n"
printf "|                           ${ULINE}${MAGENTA}PIPEX TESTER${NC} by ${YELLOW}vfurmane${NC}                           |\n"
printf "|                                                                              |\n"
printf "|                                                                              |\n"
printf "+------------------------------------------------------------------------------+\n"
printf "\n\n"

ONLY_CONFIG=0
READ_CONFIG=1

# Parse arguments
while [ $# -gt 0 ]
do
	case $1 in
		-c|--config)
			ONLY_CONFIG=1
		shift;;
		*)
		fatal_error "Unknown argument '$1'";;
	esac
done

# Config
if ! [ -f config.vars ] || [ $ONLY_CONFIG -gt 0 ]
then
	printf "\t${BOLD}Configuration${NC}\n\n"
	printf "The project directory (default: ../pipex): "
	read project_directory
	if [ -z "$project_directory" ]
	then
		project_directory="../pipex"
	fi

	if ! touch config.vars > /dev/null 2>&1
	then
		printf "${YELLOW}Unable to create the configuration file as your user...${NC}\n"
		PROJECT_DIRECTORY=$project_directory
		READ_CONFIG=0
	else
		echo "# This file was automatically generated by the pipex-tester" > config.vars
		echo "# https://github.com/vfurmane/pipex-tester" >> config.vars
		echo >> config.vars
		echo "PROJECT_DIRECTORY='$project_directory'" >> config.vars
	fi
fi

if [ $ONLY_CONFIG -gt 0 ]
then
	exit 0
fi

if [ $READ_CONFIG -gt 0 ]
then
	if ! [ -x "config.vars" ]
	then
		if ! chmod u+x run.sh > /dev/null 2>&1
		then
			fatal_error "The config.vars file is not executable...\nTry \`chmod +x config.vars\`"
		fi
	fi
	. config.vars
fi

if ! mkdir -p outs > /dev/null 2>&1
then
	fatal_error "Unable to create the out logs folder..."
fi
if ! [ -w outs ]
then
	fatal_error "Unable to write to the 'outs' folder as your user...${NC}"
fi

printf "\n"
printf "\t${BOLD}Tests${NC}\n\n"

# TEST 01
num="01"
description="The program compiles"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
pipex_test make -C $PROJECT_DIRECTORY > outs/test-01.txt 2>&1
status_code=$?
if [ $status_code -eq 0 ]
then
	result="OK"
	result_color=$GREEN
else
	if [ $status_code -eq 254 ]
	then
		result="TO"
	else
		result="KO"
	fi
	result_color=$RED
fi
printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"

# TEST 02
num="02"
description="The program is executable as ./pipex"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
if [ -x $PROJECT_DIRECTORY/pipex ]
then
	result="OK"
	result_color=$GREEN
else
	result="KO"
	result_color=$RED
fi
printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"

# TEST 03
num="03"
description="The program does not crash with no parameters"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
pipex_test $PROJECT_DIRECTORY/pipex > outs/test-03-tty.txt 2>&1
status_code=$?
if [ $status_code -le 128 ] # 128 is the last code that bash uses before signals
then
	result="OK"
	if [ $status_code -ne 0 ]
	then
		result_color=$GREEN
	else
		result_color=$YELLOW
	fi
else
	if [ $status_code -eq 254 ]
	then
		result="TO"
	else
		result="KO"
	fi
	result_color=$RED
fi
printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"

# TEST 04
num="04"
description="The program does not crash with one parameter"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
pipex_test $PROJECT_DIRECTORY/pipex "assets/deepthought.txt" > outs/test-04-tty.txt 2>&1
status_code=$?
if [ $status_code -le 128 ] # 128 is the last code that bash uses before signals
then
	result="OK"
	if [ $status_code -ne 0 ]
	then
		result_color=$GREEN
	else
		result_color=$YELLOW
	fi
else
	if [ $status_code -eq 254 ]
	then
		result="TO"
	else
		result="KO"
	fi
	result_color=$RED
fi
printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"

# TEST 05
num="05"
description="The program does not crash with two parameters"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
pipex_test $PROJECT_DIRECTORY/pipex "assets/deepthought.txt" "grep Now" > outs/test-05-tty.txt 2>&1
status_code=$?
if [ $status_code -le 128 ] # 128 is the last code that bash uses before signals
then
	result="OK"
	if [ $status_code -ne 0 ]
	then
		result_color=$GREEN
	else
		result_color=$YELLOW
	fi
else
	if [ $status_code -eq 254 ]
	then
		result="TO"
	else
		result="KO"
	fi
	result_color=$RED
fi
printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"

# TEST 06
num="06"
description="The program does not crash with three parameters"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
pipex_test $PROJECT_DIRECTORY/pipex "assets/deepthought.txt" "grep Now" "wc -w" > outs/test-06-tty.txt 2>&1
status_code=$?
if [ $status_code -le 128 ] # 128 is the last code that bash uses before signals
then
	result="OK"
	if [ $status_code -ne 0 ]
	then
		result_color=$GREEN
	else
		result_color=$YELLOW
	fi
else
	if [ $status_code -eq 254 ]
	then
		result="TO"
	else
		result="KO"
	fi
	result_color=$RED
fi
printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"

# TEST 07
num="07"
description="The program exits with the last command's status code"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
PATH=$PWD:$PATH pipex_test $PROJECT_DIRECTORY/pipex "assets/deepthought.txt" "grep Now" "./assets/exit.sh 5" "outs/test-07.txt" > outs/test-07-tty.txt 2>&1
status_code=$?
if [ $status_code -le 128 ] # 128 is the last code that bash uses before signals
then
	result="OK"
	if [ $? -eq 5 ]
	then
		result_color=$GREEN
	else
		result_color=$YELLOW
	fi
else
	if [ $status_code -eq 254 ]
	then
		result="TO"
	else
		result="KO"
	fi
	result_color=$RED
fi
printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"

# TEST 08
num="08"
description="The program handles infile's open error"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
pipex_test $PROJECT_DIRECTORY/pipex "not-existing/deepthought.txt" "grep Now" "wc -w" "outs/test-08.txt" > outs/test-08-tty.txt 2>&1
status_code=$?
if [ $status_code -eq 0 ]
then
	result="OK"
	result_color=$GREEN
else
	if [ $status_code -eq 254 ]
	then
		result="TO"
	else
		result="KO"
	fi
	result_color=$RED
fi
printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"

# TEST 09
num="09"
description="The output when infile's open error occur is correct"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
pipex_test $PROJECT_DIRECTORY/pipex "not-existing/deepthought.txt" "grep Now" "wc -w" "outs/test-09.txt" > outs/test-09-tty.txt 2>&1
< /dev/null grep Now | wc -w > outs/test-09-original.txt 2>&1
if diff outs/test-09-original.txt outs/test-09.txt > /dev/null 2>&1
then
	result="OK"
	result_color=$GREEN
else
	result="KO"
	result_color=$RED
fi
printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"

# TEST 10
num="10"
description="The program handles outfile's open error"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
pipex_test $PROJECT_DIRECTORY/pipex "assets/deepthought.txt" "grep Now" "wc -w" "not-existing/test-10.txt" > outs/test-10-tty.txt 2>&1
status_code=$?
if [ $status_code -le 128 ] # 128 is the last code that bash uses before signals
then
	result="OK"
	if [ $status_code -ne 0 ]
	then
		result_color=$GREEN
	else
		result_color=$YELLOW
	fi
else
	if [ $status_code -eq 254 ]
	then
		result="TO"
	else
		result="KO"
	fi
	result_color=$RED
fi
printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"

# TEST 11
num="11"
description="The program handles execve errors"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
chmod 644 assets/deepthought.txt
PATH=$PWD:$PATH pipex_test $PROJECT_DIRECTORY/pipex "assets/deepthought.txt" "cat" "./assets/not-executable" "outs/test-11.txt" > outs/test-11-tty.txt 2>&1
status_code=$?
if [ $status_code -le 128 ] # 128 is the last code that bash uses before signals
then
	result="OK"
	if [ $status_code -ne 0 ]
	then
		result_color=$GREEN
	else
		result_color=$YELLOW
	fi
else
	if [ $status_code -eq 254 ]
	then
		result="TO"
	else
		result="KO"
	fi
	result_color=$RED
fi
printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"

# TEST 12
num="12"
description="The program handles path that doesn't exist"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
PATH=/not/existing:$PATH pipex_test $PROJECT_DIRECTORY/pipex "assets/deepthought.txt" "grep Now" "wc -w" "outs/test-12.txt" > outs/test-12-tty.txt 2>&1
status_code=$?
if [ $status_code -eq 0 ]
then
	result="OK"
	result_color=$GREEN
else
	if [ $status_code -eq 254 ]
	then
		result="TO"
	else
		result="KO"
	fi
	result_color=$RED
fi
printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"

# **************************************************************************** #

printf "\n${ULINE}The next tests will use the following command:${NC}\n"
printf "$PROJECT_DIRECTORY/pipex \"assets/deepthought.txt\" \"cat\" \"ls\" \"outs/test-xx.txt\"\n\n"

# TEST 13
num="13"
description="The program handles the command"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
pipex_test $PROJECT_DIRECTORY/pipex "assets/deepthought.txt" "cat" "ls" "outs/test-13.txt" > outs/test-13-tty.txt 2>&1
status_code=$?
if [ $status_code -eq 0 ]
then
	result="OK"
	result_color=$GREEN
else
	if [ $status_code -eq 254 ]
	then
		result="TO"
	else
		result="KO"
	fi
	result_color=$RED
fi
printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"

# TEST 14
num="14"
description="The output of the command is correct"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
pipex_test $PROJECT_DIRECTORY/pipex "assets/deepthought.txt" "cat" "ls" "outs/test-14.txt" > outs/test-14-tty.txt 2>&1
< assets/deepthought.txt cat | ls > outs/test-14-original.txt 2>&1
if diff outs/test-14-original.txt outs/test-14.txt > /dev/null 2>&1
then
	result="OK"
	result_color=$GREEN
else
	result="KO"
	result_color=$RED
fi
printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"

# **************************************************************************** #

printf "\n${ULINE}The next tests will use the following command:${NC}\n"
printf "$PROJECT_DIRECTORY/pipex \"assets/deepthought.txt\" \"grep Now\" \"head -2\" \"outs/test-xx.txt\"\n\n"

# TEST 15
num="15"
description="The program handles the command"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
pipex_test $PROJECT_DIRECTORY/pipex "assets/deepthought.txt" "grep Now" "head -2" "outs/test-15.txt" > outs/test-15-tty.txt 2>&1
status_code=$?
if [ $status_code -eq 0 ]
then
	result="OK"
	result_color=$GREEN
else
	if [ $status_code -eq 254 ]
	then
		result="TO"
	else
		result="KO"
	fi
	result_color=$RED
fi
printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"

# TEST 16
num="16"
description="The output of the command is correct"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
pipex_test $PROJECT_DIRECTORY/pipex "assets/deepthought.txt" "grep Now" "head -2" "outs/test-16.txt" > outs/test-16-tty.txt 2>&1
< assets/deepthought.txt grep Now | head -2 > outs/test-16-original.txt 2>&1
if diff outs/test-16-original.txt outs/test-16.txt > /dev/null 2>&1
then
	result="OK"
	result_color=$GREEN
else
	result="KO"
	result_color=$RED
fi
printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"

# **************************************************************************** #

printf "\n${ULINE}The next tests will use the following command:${NC}\n"
printf "$PROJECT_DIRECTORY/pipex \"assets/deepthought.txt\" \"grep Now\" \"wc -w\" \"outs/test-xx.txt\"\n\n"

# TEST 17
num="17"
description="The program handles the command"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
pipex_test $PROJECT_DIRECTORY/pipex "assets/deepthought.txt" "grep Now" "wc -w" "outs/test-17.txt" > outs/test-17-tty.txt 2>&1
status_code=$?
if [ $status_code -eq 0 ]
then
	result="OK"
	result_color=$GREEN
else
	if [ $status_code -eq 254 ]
	then
		result="TO"
	else
		result="KO"
	fi
	result_color=$RED
fi
printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"

# TEST 18
num="18"
description="The output of the command is correct"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
pipex_test $PROJECT_DIRECTORY/pipex "assets/deepthought.txt" "grep Now" "wc -w" "outs/test-18.txt" > outs/test-18-tty.txt 2>&1
< assets/deepthought.txt grep Now | wc -w > outs/test-18-original.txt 2>&1
if diff outs/test-18-original.txt outs/test-18.txt > /dev/null 2>&1
then
	result="OK"
	result_color=$GREEN
else
	result="KO"
	result_color=$RED
fi
printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"

# **************************************************************************** #

printf "\n${ULINE}The next tests will use the following command:${NC}\n"
printf "$PROJECT_DIRECTORY/pipex \"assets/deepthought.txt\" \"grep Now\" \"cat\" \"outs/test-xx.txt\"\n"
printf "${ULINE}then:${NC}\n"
printf "$PROJECT_DIRECTORY/pipex \"assets/deepthought.txt\" \"wc -w\" \"cat\" \"outs/test-xx.txt\"\n\n"

# TEST 19
num="19"
description="The program handles the command"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
pipex_test $PROJECT_DIRECTORY/pipex "assets/deepthought.txt" "grep Now" "cat" "outs/test-19.txt" > outs/test-19.0-tty.txt 2>&1
status_code=$?
pipex_test $PROJECT_DIRECTORY/pipex "assets/deepthought.txt" "wc -w" "cat" "outs/test-19.txt" > outs/test-19.1-tty.txt 2>&1
if [ $status_code -eq 0 ] && [ $? -eq 0 ]
then
	result="OK"
	result_color=$GREEN
else
	if [ $status_code -eq 254 ]
	then
		result="TO"
	else
		result="KO"
	fi
	result_color=$RED
fi
printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"

# TEST 20
num="20"
description="The output of the command is correct"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
pipex_test $PROJECT_DIRECTORY/pipex "assets/deepthought.txt" "grep Now" "cat" "outs/test-20.txt" > outs/test-20.0-tty.txt 2>&1
pipex_test $PROJECT_DIRECTORY/pipex "assets/deepthought.txt" "wc -w" "cat" "outs/test-20.txt" > outs/test-20.1-tty.txt 2>&1
< assets/deepthought.txt grep Now | cat > outs/test-20-original.txt
< assets/deepthought.txt wc -w | cat > outs/test-20-original.txt
if diff outs/test-20-original.txt outs/test-20.txt > /dev/null 2>&1
then
	result="OK"
	result_color=$GREEN
else
	result="KO"
	result_color=$RED
fi
printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"

# **************************************************************************** #

printf "\n${ULINE}The next tests will use the following command:${NC}\n"
printf "$PROJECT_DIRECTORY/pipex \"assets/deepthought.txt\" \"notexisting\" \"wc\" \"outs/test-xx.txt\"\n"
printf "${ULINE}(notexisting is a command that is not supposed to exist)${NC}\n\n"

# TEST 21
num="21"
description="The program handles the command"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
pipex_test $PROJECT_DIRECTORY/pipex "assets/deepthought.txt" "notexisting" "wc" "outs/test-21.txt" > outs/test-21-tty.txt 2>&1
status_code=$?
if [ $status_code -le 128 ] # 128 is the last code that bash uses before signals
then
	result="OK"
	if [ $status_code -eq 0 ]
	then
		result_color=$GREEN
	else
		result_color=$YELLOW
	fi
else
	if [ $status_code -eq 254 ]
	then
		result="TO"
	else
		result="KO"
	fi
	result_color=$RED
fi
printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"

# TEST 22
num="22"
description="The output of the command contains 'command not found'"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
pipex_test $PROJECT_DIRECTORY/pipex "assets/deepthought.txt" "notexisting" "wc" "outs/test-22.txt" > outs/test-22-tty.txt 2>&1
if grep "command not found" outs/test-22-tty.txt > /dev/null 2>&1
then
	result="OK"
	result_color=$GREEN
else
	result="KO"
	result_color=$RED
fi
printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"

# TEST 23
num="23"
description="The output of the command is correct"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
pipex_test $PROJECT_DIRECTORY/pipex "assets/deepthought.txt" "notexisting" "wc" "outs/test-23.txt" > outs/test-23-tty.txt 2>&1
< /dev/null cat | wc > outs/test-23-original.txt 2>&1
if diff outs/test-23-original.txt outs/test-23.txt > /dev/null 2>&1
then
	result="OK"
	result_color=$GREEN
else
	result="KO"
	result_color=$RED
fi
printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"

# **************************************************************************** #

printf "\n${ULINE}The next tests will use the following command:${NC}\n"
printf "$PROJECT_DIRECTORY/pipex \"assets/deepthought.txt\" \"cat\" \"notexisting\" \"outs/test-xx.txt\"\n"
printf "${ULINE}(notexisting is a command that is not supposed to exist)${NC}\n\n"

# TEST 24
num="24"
description="The program exits with the right status code"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
pipex_test $PROJECT_DIRECTORY/pipex "assets/deepthought.txt" "cat" "notexisting" "outs/test-24.txt" > outs/test-24-tty.txt 2>&1
status_code=$?
if [ $status_code -le 128 ] # 128 is the last code that bash uses before signals
then
	result="OK"
	if [ $status_code -eq 127 ]
	then
		result_color=$GREEN
	else
		result_color=$YELLOW
	fi
else
	if [ $status_code -eq 254 ]
	then
		result="TO"
	else
		result="KO"
	fi
	result_color=$RED
fi
printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"

# TEST 25
num="25"
description="The output of the command contains 'command not found'"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
pipex_test $PROJECT_DIRECTORY/pipex "assets/deepthought.txt" "cat" "notexisting" "outs/test-25.txt" > outs/test-25-tty.txt 2>&1
if grep "command not found" outs/test-25-tty.txt > /dev/null 2>&1
then
	result="OK"
	result_color=$GREEN
else
	result="KO"
	result_color=$RED
fi
printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"

# TEST 26
num="26"
description="The output of the command is correct"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
pipex_test $PROJECT_DIRECTORY/pipex "assets/deepthought.txt" "cat" "notexisting" "outs/test-26.txt" > outs/test-26-tty.txt 2>&1
< assets/deepthought.txt cat | cat /dev/null > outs/test-26-original.txt 2>&1
if diff outs/test-26-original.txt outs/test-26.txt > /dev/null 2>&1
then
	result="OK"
	result_color=$GREEN
else
	result="KO"
	result_color=$RED
fi
printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"

# **************************************************************************** #

printf "\n${ULINE}The next tests will use the following command:${NC}\n"
printf "$PROJECT_DIRECTORY/pipex \"/dev/urandom\" \"cat\" \"head -1\" \"outs/test-xx.txt\"\n\n"

# TEST 27
num="27"
description="The program does not timeout"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
pipex_test $PROJECT_DIRECTORY/pipex "/dev/urandom" "cat" "head -1" "outs/test-27.txt" > outs/test-27-tty.txt 2>&1 &
status_code=$?
if [ $status_code -eq 0 ]
then
	result="OK"
	result_color=$GREEN
else
	if [ $status_code -eq 254 ]
	then
		result="TO"
	else
		result="KO"
	fi
	result_color=$RED
fi
printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"

if grep -i leak outs/test-*-tty.txt > /dev/null 2>&1
then
	printf "\n${RED}Leaks detected...${NC}\n"
else
	printf "\n${GREEN}No leak detected !${NC}\n"
fi
