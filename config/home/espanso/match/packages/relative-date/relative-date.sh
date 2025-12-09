#!/bin/bash

input=$1

# Extract the operator (+ or -) and the number from the input
operator="${input:0:1}"
number="${input:1:-1}"

# Determine the time unit based on the last character of the input
unit="${input: -1}"

# Map the time unit to the corresponding format string for the date command
case $unit in
  d) format="${operator}${number} days" ;;
  w) format="${operator}$((number * 7)) days" ;;
  m) format="${operator}${number} months" ;;
  y) format="${operator}$((number * 12)) months" ;;
  *) echo "Invalid input format. Please use +2d, +2w, or +2m." && exit 1 ;;
esac

# Perform the date calculation and print the result
date --date="$operator $format" +%F
