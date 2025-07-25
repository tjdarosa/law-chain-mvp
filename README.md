# law-chain-mvp
MVP for a business proposal designed in "blockchain technologies and cryptocurrencies" course at UFSC. The idea is a hibrid system that uses a traditional database to store files and uses blockchain to keep integrity and auditability of these files.


## Requirements

__*NOTE: This project is based on Ubuntu 22.04. The requirements and steps specified below were not tested in other OSes and may not work on them.*__

Requirement | Version
--- | --- 
docker | 28.2.2 
docker-compose | 1.29.2 
curl | 7.81.0
jq | 1.6
git | latest
tar | 1.34
go | 1.18.1
nodejs | 12.22.9
 
## 1 - Downloading and installing Hyperledger Fabric binaries (v2.5):


Donwload (it is not needed to download anymore as ```install-fabric.sh``` file was added on the project):
```
curl -sSLO https://raw.githubusercontent.com/hyperledger/fabric/main/scripts/install-fabric.sh && chmod +x install-fabric.sh
```

Install:
```
./install-fabric.sh -f 2.5.13 -c 1.5.15
```

## 2 - Go to the test-network dir

```cd ./law-chain-mvp-project/test-network``` 

## 3 - Start the network with the all organizations + orderer and create the channel "law-channel"

```chmod +x ./scripts/setup_network.sh && ./scripts/setup_network.sh``` 

## 4 - Checking containers info

### Which containers were created and are up
```docker ps -a```

### Check container logs
```docker logs <container_name>```  
Executing with ```-f``` will keep the logs running.

### Enter a container to debug/test if needed
```docker exec -it <container_name> bash```

## 5 - Take the network down
```./network.sh down```