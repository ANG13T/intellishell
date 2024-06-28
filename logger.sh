#!/bin/bash

# TERMINAL HISTORY LOGGER / ANALYZER
# This script logs all terminal commands and outputs to a specified directory.
# Saves each history session in a text file with a timestamp.

LOG_DIR="/Users/angelinatsuboi/Desktop/AT-Files/Cybersecurity/Research/Terminal_Logs"

mkdir -p "$LOG_DIR"

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

# Create the log directory if it does not exist
SESSION_DIR = "$LOG_DIR/$TIMESTAMP"

mkdir "$SESSION_DIR"

# Define the log file path with the timestamp
LOG_FILE="$LOG_DIR/session.txt"

# Start logging session to the specified file
script "$LOG_FILE"

# Open the cleaned log file in iTerm (replace with your actual iTerm launch command, if needed)
open -a iTerm "$LOG_FILE"

# When iTerm exits, stop logging
exit

touch "$LOG_DIR/summary.txt"

ruby analyze.rb "$LOG_DIR/summary.txt"
