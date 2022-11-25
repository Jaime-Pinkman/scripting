#!/bin/bash

count=1
wrongs=0
rights=0
RED='\e[31m'
GREEN='\e[32m'
RESET='\e[0m'
declare -a numbers
while :
do
	echo "Step number $count"
	read -p "Enter one number ( q to quit ) : " x
	if [ $x = "q" ]; then
        break
	fi
    if ! [[ $x =~ ^[0-9]+$ ]]; then
        break
    else
        if ! [ $x -lt 10 ] && [ $x -gt 0 ]; then
            break
        fi
    fi
    number=$(( $RANDOM % 10 ))
    if [ $x == $number ]; then
        rights=$((rights+1))
        number_string="${GREEN}${number}${RESET}"
        numbers+=(${number_string})
        echo "You got it! It was $number"
    else
        wrongs=$((wrongs+1))
        number_string="${RED}${number}${RESET}"
        numbers+=(${number_string})
        echo "The number was $number. Lets try one more time!"
    fi
    echo "Hit: $(( ( $rights * 100 ) / $count ))% Miss: $(( ( $wrongs * 100 ) / $count ))%"
    echo "Last 10 items: ${numbers[@]: -10}"
    count=$((count+1))
    echo
done