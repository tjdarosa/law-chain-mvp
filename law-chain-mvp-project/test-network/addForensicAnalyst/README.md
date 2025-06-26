## Adding ForensicAnalyst to the test network

You can use the `addForensicAnalyst.sh` script to add another organization to the Fabric test network. The `addForensicAnalyst.sh` script generates the ForensicAnalyst crypto material, creates an ForensicAnalyst organization definition, and adds ForensicAnalyst to a channel on the test network.

You first need to run `./network.sh up createChannel` in the `test-network` directory before you can run the `addForensicAnalyst.sh` script.

```
./network.sh up createChannel
cd addForensicAnalyst
./addForensicAnalyst.sh up
```

If you used `network.sh` to create a channel other than the default `law-channel`, you need pass that name to the `addforensicanalyst.sh` script.
```
./network.sh up createChannel -c channel1
cd addForensicAnalyst
./addForensicAnalyst.sh up -c channel1
```

You can also re-run the `addForensicAnalyst.sh` script to add ForensicAnalyst to additional channels.
```
cd ..
./network.sh createChannel -c channel2
cd addForensicAnalyst
./addForensicAnalyst.sh up -c channel2
```

For more information, use `./addForensicAnalyst.sh -h` to see the `addForensicAnalyst.sh` help text.
