#!/bin/bash

# Start the network
echo "Starting the network..."
./network.sh up
if [ $? -ne 0 ]; then
    echo "Failed to start the network"
    exit 1
fi

# Create the channel
echo "Creating law-channel..."
./network.sh createChannel -c law-channel

# Add Forensic Analyst
echo "Adding Forensic Analyst..."
cd ./addForensicAnalyst/ && ./addForensicAnalyst.sh up -c law-channel
if [ $? -ne 0 ]; then
    echo "Failed to add Forensic Analyst"
    exit 1
fi
cd ..

# Add Prosecutor
echo "Adding Prosecutor..."
cd ./addProsecutor/ && ./addProsecutor.sh up -c law-channel
if [ $? -ne 0 ]; then
    echo "Failed to add Prosecutor"
    exit 1
fi
cd ..

# Add Courtroom Personnel
echo "Adding Courtroom Personnel..."
cd ./addCourtroomPersonnel/ && ./addCourtroomPersonnel.sh up -c law-channel
if [ $? -ne 0 ]; then
    echo "Failed to add Courtroom Personnel"
    exit 1
fi
cd ..

echo "All components deployed successfully!"
