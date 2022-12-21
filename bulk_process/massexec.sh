#!/bin/bash

# Process multiple files

# Parse command line options
while getopts "d:e:c:n:" opt; do
  case "$opt" in
    d)
      # Directory to search for files
      dir="$OPTARG"
      ;;
    e)
      # File name pattern to match
      pattern="$OPTARG"
      ;;
    c)
      # Command to run on each file
      cmd="$OPTARG"
      ;;
    n)
      # Maximum number of processes to run concurrently
      num_procs="$OPTARG"
      ;;
    *)
      # Invalid option
      exit 1
      ;;
  esac
done

# Ensure all required options have been set
for var in dir pattern cmd num_procs; do
  if [ -z "${!var}" ]; then
    echo "$var is unset"
    exit 1
  fi
done

# Function to print the number of files that have been processed so far
function print_processed_count() {
    echo "Already processed: $processed_count"
}

# Function to print the number of files that are left to process
function print_left_count() {
    echo "Files left: $left_count"
}

# Set up signal handlers to print the number of processed and remaining files
trap print_processed_count SIGUSR1
trap print_left_count SIGUSR2

# Function to get the next file to process
function next_file() {
    # Check if there are any files left to process
    if [ "${#files[@]}" -gt 0 ]; then
      # Get the last file in the array and remove it
      next_file="${files[${#files[@]}-1]}"
      unset "files[${#files[@]}-1]"
      return 0
    fi
    return 1
}

# Function to wait for a child process to finish, while also checking for signals
function signals_aware_wait() {
    wait -n
    wait_status=$?
    while [ $wait_status -gt 127 ]; do
      wait -n
      wait_status=$?
    done
}

# Find all files matching the given pattern in the specified directory
path="$dir/$pattern"
files=( $path )

# Initialize counters for the number of files left to process and the number of files processed so far
left_count="${#files[@]}" # count how many files were found
# initialize the count of processed files to 0
processed_count=0

# Start the maximum number of processes, or the number of files if there are fewer than the max
min=$((num_procs < left_count ? num_procs : left_count)) # determine the minimum number of processes to start
for _ in $(seq 1 $min); do
    # Get the next file to process
    next_file
    # Run the command on the next file as a background process
    eval "$cmd $next_file" &
done

# Main loop: wait for processes to finish and start new ones as needed
while : ; do
  # Wait for a child process to finish, while also checking for signals
  signals_aware_wait
  # Decrement the counter for the number of files left to process
  left_count=$((left_count-1))
  # Increment the count of processed files
  processed_count=$((processed_count+1))
  # If there are still files left to process, start a new process on the next file
  if [ "${#files[@]}" -gt 0 ]; then
      next_file
      eval "$cmd $next_file" &
  fi
  # If all files have been processed, exit the loop
  if [ $left_count -eq 0 ]; then
      break
  fi
done

# Wait for all processes to finish
wait

# End script
echo 'END'
