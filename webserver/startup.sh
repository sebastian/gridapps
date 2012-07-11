#!/bin/bash

echo "Starting Services..."

#screen -wipe redis
#screen -d -m -S redis
#screen -S redis -X redis/redis-server

redis/redis-server redis/redis.conf

echo "Done!"
