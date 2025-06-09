#!/bin/bash

# Script to stop MongoDB sharded cluster
echo "Stopping MongoDB Sharded Cluster..."

# Stop mongos
echo "Stopping mongos..."
if [ -f /home/taha/sharding_mongodb_project/mongodb-sharding/mongos.pid ]; then
    kill $(cat /home/taha/sharding_mongodb_project/mongodb-sharding/mongos.pid)
fi

# Stop shard servers
echo "Stopping shard servers..."
if [ -f /home/taha/sharding_mongodb_project/mongodb-sharding/shard1/shardsvr1.pid ]; then
    kill $(cat /home/taha/sharding_mongodb_project/mongodb-sharding/shard1/shardsvr1.pid)
fi
if [ -f /home/taha/sharding_mongodb_project/mongodb-sharding/shard2/shardsvr2.pid ]; then
    kill $(cat /home/taha/sharding_mongodb_project/mongodb-sharding/shard2/shardsvr2.pid)
fi
if [ -f /home/taha/sharding_mongodb_project/mongodb-sharding/shard3/shardsvr3.pid ]; then
    kill $(cat /home/taha/sharding_mongodb_project/mongodb-sharding/shard3/shardsvr3.pid)
fi

# Stop config servers
echo "Stopping config servers..."
if [ -f /home/taha/sharding_mongodb_project/mongodb-sharding/config/configsvr1.pid ]; then
    kill $(cat /home/taha/sharding_mongodb_project/mongodb-sharding/config/configsvr1.pid)
fi
if [ -f /home/taha/sharding_mongodb_project/mongodb-sharding/config/configsvr2.pid ]; then
    kill $(cat /home/taha/sharding_mongodb_project/mongodb-sharding/config/configsvr2.pid)
fi
if [ -f /home/taha/sharding_mongodb_project/mongodb-sharding/config/configsvr3.pid ]; then
    kill $(cat /home/taha/sharding_mongodb_project/mongodb-sharding/config/configsvr3.pid)
fi

echo "MongoDB Sharded Cluster stopped successfully!" 