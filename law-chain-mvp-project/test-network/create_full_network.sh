./network.sh down 
docker ps -a -q 
docker container prune -f 
./network.sh up createChannel -c law-channel 
cd ./addForensicAnalyst/ 
./addForensicAnalyst.sh up -c law-channel 
cd ../addProsecutor/ 
./addProsecutor.sh up -c law-channel 
cd ../addCourtroomPersonnel/ 
./addCourtroomPersonnel.sh up -c law-channel 
cd .. 