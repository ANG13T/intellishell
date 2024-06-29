#!/bin/bash

# TERMINAL HISTORY LOGGER / ANALYZER
# This script logs all terminal commands and outputs to a specified directory.
# Saves each history session in a text file with a timestamp.

# INPUT: LOGGING DIRECTORY, TIMESTAMP, and SESSION CATALOG

LOG_DIR=$1
SESSION_CATALOG=$2
TIMESTAMP=$3

SESSION_DIR="$LOG_DIR/$TIMESTAMP"
LOG_FILE="$SESSION_DIR/session.txt"
SUMMARY_FILE="$SESSION_DIR/summary.txt"


mkdir -p "$LOG_DIR"

# Create the log directory if it does not exist
mkdir -p "$SESSION_DIR"

touch "$LOG_FILE"

chmod u+w "$LOG_FILE" || { echo "Failed to set write permissions for log file: $LOG_FILE"; exit 1; }

touch "$SUMMARY_FILE"

# Start logging session to the specified file
script -q "$LOG_FILE"

exit
echo "Session logging completed and analyzed at $SESSION_DIR."