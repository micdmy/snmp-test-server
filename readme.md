# Overview
This repo cointains tools for testing snmp. In particular:

- Snmp v2c v3 capable servers (docker files). There are two servers. One uses blumenthal the other reeder key extension method. The servers use net-snmp 5.9 library.
- `snmpd.conf` configuration file for server, which contains user credentials you can use or tweak. Currently there is one v2c user and 31 v3 users (each with different Auth and Priv combination)
- `snmp_users` file is a config file for wireshark, to easily decrypt 3v AuthPriv type snmp messages. Put it to `${HOME}/.config/`
- `all_getsnmp` is a script that uses snmpget to send requests for `sys descr` for every user in server. You can use it to see if server works.

# Build snmp test servers

    docker build -f Dockerfile.blumenthal -t net-snmp-blumenthal .

    docker build -f Dockerfile.reeder -t net-snmp-reeder .



## Run one of servers:

    docker run -dit --name net-snmp-blumenthal-container -p 161:161/udp --mount type=bind,source="$(pwd)",target=/snmpdconf net-snmp-blumenthal

    docker run -dit --name net-snmp-reeder-container -p 161:161/udp --mount type=bind,source="$(pwd)",target=/snmpdconf net-snmp-reeder

From now on use `net-snmp-blumenthal-container` or `net-snmp-reeder-container`. I will refer to it as `container`.

## Check if snpmd.config was loaded without errors:

    docker logs container

## Re-run server after snmpd.conf change

    docker stop container && docker rm container

The do `docker run ...` like before.

# Test if server responds to client request:
Adjust ip if your docker container has different ip:

    ./all_getsnmp.sh 172.17.0.2

Because client is your host machine ( I assume you have net-snmp installed), it won't support reeder server.

For bluementhal srv, all Auth/Priv combinations should succeess.
For reeder srv, 5 following Auth/Priv combinations will fail:

    Testing Auth=Md5, Priv=AES192, User=md5aes192, APass=authpassmd5aes192, PPass=privpassmd5aes192
    Timeout: No Response from 172.17.0.2.
    Testing Auth=Md5, Priv=AES256, User=md5aes256, APass=authpassmd5aes256, PPass=privpassmd5aes256
    Timeout: No Response from 172.17.0.2.
    Testing Auth=Sha1, Priv=AES192, User=sha1aes192, APass=authpasssha1aes192, PPass=privpasssha1aes192
    Timeout: No Response from 172.17.0.2.
    Testing Auth=Sha1, Priv=AES256, User=sha1aes256, APass=authpasssha1aes256, PPass=privpasssha1aes256
    Timeout: No Response from 172.17.0.2.
    Testing Auth=Sha224, Priv=AES256, User=sha224aes256, APass=authpasssha224aes256, PPass=privpasssha224aes256
    Timeout: No Response from 172.17.0.2.

You may use getsnmp on reeder container to test reeder.
