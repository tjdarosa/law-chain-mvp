## Adding CourtroomPersonnel to the test network

You can use the `addCourtroomPersonnel.sh` script to add another organization to the Fabric test network. The `addCourtroomPersonnel.sh` script generates the CourtroomPersonnel crypto material, creates an CourtroomPersonnel organization definition, and adds CourtroomPersonnel to a channel on the test network.

You first need to run `./network.sh up createChannel` in the `test-network` directory before you can run the `addCourtroomPersonnel.sh` script.

```
./network.sh up createChannel
cd addCourtroomPersonnel
./addCourtroomPersonnel.sh up
```

If you used `network.sh` to create a channel other than the default `mychannel`, you need pass that name to the `addcourtroompersonnel.sh` script.
```
./network.sh up createChannel -c channel1
cd addCourtroomPersonnel
./addCourtroomPersonnel.sh up -c channel1
```

You can also re-run the `addCourtroomPersonnel.sh` script to add CourtroomPersonnel to additional channels.
```
cd ..
./network.sh createChannel -c channel2
cd addCourtroomPersonnel
./addCourtroomPersonnel.sh up -c channel2
```

For more information, use `./addCourtroomPersonnel.sh -h` to see the `addCourtroomPersonnel.sh` help text.
