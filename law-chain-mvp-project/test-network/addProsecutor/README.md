## Adding Prosecutor to the test network

You can use the `addProsecutor.sh` script to add another organization to the Fabric test network. The `addProsecutor.sh` script generates the Prosecutor crypto material, creates an Prosecutor organization definition, and adds Prosecutor to a channel on the test network.

You first need to run `./network.sh up createChannel` in the `test-network` directory before you can run the `addProsecutor.sh` script.

```
./network.sh up createChannel
cd addProsecutor
./addProsecutor.sh up
```

If you used `network.sh` to create a channel other than the default `law-channel`, you need pass that name to the `addprosecutor.sh` script.
```
./network.sh up createChannel -c channel1
cd addProsecutor
./addProsecutor.sh up -c channel1
```

You can also re-run the `addProsecutor.sh` script to add Prosecutor to additional channels.
```
cd ..
./network.sh createChannel -c channel2
cd addProsecutor
./addProsecutor.sh up -c channel2
```

For more information, use `./addProsecutor.sh -h` to see the `addProsecutor.sh` help text.
