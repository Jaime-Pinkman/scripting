#!/bin/bash

# Define the array of puzzle pieces
arr=("0" "1" "2" "3" "4" "5" "6" "7" "8" "9" "A" "B" "C" "D" "E" "F" "@")

# Save a copy of the original puzzle for checking later
chk=("${arr[@]}")

# Define the allowed movements
mov=("4" "-4" "1" "-1")

# Initialize some variables
buf=""
now=16
pre=0
count=0

# Function to shuffle the puzzle
shuffle() {
    # Seed the random number generator
    RANDOM=$$$(date +%s)

    # Shuffle the array
    for ((i=1; i<=16; i++)); do
        # Generate a random index between 1 and 15
        j=$(($RANDOM %15 + 1))
        # Swap the element at index i with the element at index j
        temp=${arr[$i]}
        arr[$i]=${arr[$j]}
        arr[$j]=$temp
    done
}

# Function to check if the puzzle is in the original configuration
check() {
    # Initialize result to 0 (puzzle is solved)
    res=0
    # Check if each element in the puzzle is in the same position as in the original configuration
    for (( k = 1; k <= 16; k++ )) {
        # If any element is not in the same position, set result to 1 (puzzle is not solved)
        [ ${arr[k]} != ${chk[k]} ] && res=1
    }
    # Return result
    echo $res
}

# Function to determine the number of spaces to move the empty puzzle piece (indicated by "@")
# in order to reach the puzzle piece with the specified value
navigate() {
    # Initialize variables to store the indices of the empty puzzle piece and the target puzzle piece
    declare -i dest
    declare -i src
    # Find the indices of the empty puzzle piece and the target puzzle piece
    for i in "${!arr[@]}"; do
        if [[ "${arr[$i]}" = "$1" ]]; then
            dest=${i}
        fi
        if [[ "${arr[$i]}" = "@" ]]; then
            src=${i}
        fi
    done

    # Calculate the difference between the indices (number of spaces to move)
    diff=`expr $dest - $src`

    # Return the difference
    echo $diff
}

# Main function to play the puzzle game
main() {
    # Shuffle the puzzle
    shuffle
    # Find the initial position of the empty puzzle piece
    for i in "${!arr[@]}"; do
        if [[ "${arr[$i]}" = "@" ]]; then
            now=${i}
        fi
    done
    # Initialize the move counter and a flag for invalid moves
    declare -i count=1
    declare -i flag=0
    # Start an infinite loop
    while :
    do
        # Print the current state of the puzzle
        clear
        echo "Ход № " $count
        printf \\n
        for i in {1..16}
        do
            echo -n "${arr[i]}"
            [ `expr $i % 4` -eq 0 ] && printf \\n
        done
        [ `check` -eq 0 ] && break

        pre=$now
        mv=0
        printf \\n
        if [[ $flag == 1 ]]; then
            echo $'Неверный ход! \nНевозможно костяшку передвинуть туда. \nМожно выбрать другие ячейки.'
            printf \\n
        fi
        echo "Ваш ход (q - выход):"

        read -s -n 1 k
        [ $k = "q" ] && break
        mv=(`navigate $k`)
        if ! [[ " ${mov[@]} " =~ " ${mv} " ]]; then
            flag=1
            continue
        fi
        flag=0
        echo $flag
        count=`expr $count + 1`

        now=`expr $now + $mv`
        buf=${arr[now]}
        arr[$now]=${arr[pre]}
        arr[$pre]=$buf

    done
}

main
