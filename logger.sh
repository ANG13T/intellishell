#!/bin/bash
/*
 * TERMINAL HISTORY LOGGER / ANALYZER
 * This script logs all terminal commands and outputs to a specified directory.
 * Saves each history session in a text file with a timestamp.
 *
 */

LOG_DIR=""
OPEN_AI_TOKEN = ""

# Generate a timestamp for the log filename
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

# Define the log file path with the timestamp
LOG_FILE="$LOG_DIR/$TIMESTAMP.txt"

# Feed the contents into AI and title the sesssion

# Makes a header section as a title containing the following:
# - Timestamp
# - User
# - AI Analyis

# Start logging session to the specified file
script "$LOG_FILE"

# Add any additional commands you want to execute upon starting iTerm
# Example: echo "Welcome to iTerm!"

# Start iTerm (replace with your actual iTerm launch command, if needed)
open -a iTerm

# When iTerm exits, stop logging
exit

