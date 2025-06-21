docker stop $(docker ps -a -q) # stop all containers
docker container prune -f # remove all stopped containers