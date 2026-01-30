#!/bin/bash

# Exit on error
set -e

# --- Install Dependencies ---
# echo "Installing Python dependencies..."
# pip install -r requirements.txt

# echo "Installing Node.js dependencies for avatar server..."
# (cd avatar-server && npm install)

# --- Cleanup any existing processes ---
echo "Cleaning up any existing processes..."
pkill -f "node server.js" || true
pkill -f "python main.py" || true
sleep 1

# --- Start Servers ---
echo "Starting Avatar Server in the background..."
(cd avatar-server && node server.js) &
AVATAR_PID=$!

echo "Starting Game Server..."
# Use 'trap' to ensure cleanup happens on exit
trap "kill $AVATAR_PID" EXIT

# Initialize conda for this shell session
eval "$(conda shell.bash hook)" 2>/dev/null || eval "$(/home/$USER/miniconda3/bin/conda shell.bash hook)" 2>/dev/null || eval "$(/home/$USER/anaconda3/bin/conda shell.bash hook)" 2>/dev/null

# Activate the conda environment and run the Python server
conda activate vivitsu
python main.py

# --- Cleanup ---
# The trap command above will handle the cleanup.
# When the python server is stopped (Ctrl+C), it will kill the avatar server.

