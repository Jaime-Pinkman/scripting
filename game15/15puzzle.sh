#!/bin/bash

arr=("0" "1" "2" "3" "4" "5" "6" "7" "8" "9" "A" "B" "C" "D" "E" "F" "@")
chk=("${arr[@]}")

mov=("4" "-4" "1" "-1")
buf=""
now=16
pre=0
count=0

shuffle() {
    array_length=${#arr[@]}

    # Seed the random number generator
    RANDOM=$$$(date +%s)

    # Shuffle the array
    for ((i=0; i<$array_length; i++)); do
        # Generate a random index between 0 and the number of elements in the array
        j=$(($RANDOM % $array_length))
        # Swap the element at index i with the element at index j
        temp=${arr[$i]}
        arr[$i]=${arr[$j]}
        arr[$j]=$temp
    done
}

set now

check() {
    res=0
    for (( k = 1; k <= 16; k++ )) {
        [ ${arr[k]} != ${chk[k]} ] && res=1
    }
    echo $res
}

navigate() {
    declare -i dest
    declare -i src
    for i in "${!arr[@]}"; do
        if [[ "${arr[$i]}" = "$1" ]]; then
            dest=${i}
        fi
        if [[ "${arr[$i]}" = "@" ]]; then
            src=${i}
        fi
    done

    diff=`expr $dest - $src`
    echo $diff
}

main() {
    shuffle
    [ `check` -eq 0 ] && break
    for i in "${!arr[@]}"; do
        if [[ "${arr[$i]}" = "@" ]]; then
            now=${i}
        fi
    done
    declare -i count=0
    while :
    do
        clear

        for i in {1..16}
        do
            echo -n "${arr[i]}"
            [ `expr $i % 4` -eq 0 ] && printf \\n
        done

        pre=$now
        mv=0

        read -s -n 1 k
        mv=(`navigate $k`)


        if [ $mv -ne 0 ]; then
            now=`expr $now + $mv`
            buf=${arr[now]}
            arr[$now]=${arr[pre]}
            arr[$pre]=$buf
        fi

    done
}

main
