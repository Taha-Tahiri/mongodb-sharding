#!/bin/bash

# Script to start MongoDB sharded cluster
echo "Starting MongoDB Sharded Cluster..."

# Create data directories
echo "Creating data directories..."
mkdir -p /home/taha/sharding_mongodb_project/mongodb-sharding/config/data1
mkdir -p /home/taha/sharding_mongodb_project/mongodb-sharding/config/data2
mkdir -p /home/taha/sharding_mongodb_project/mongodb-sharding/config/data3
mkdir -p /home/taha/sharding_mongodb_project/mongodb-sharding/shard1/data
mkdir -p /home/taha/sharding_mongodb_project/mongodb-sharding/shard2/data
mkdir -p /home/taha/sharding_mongodb_project/mongodb-sharding/shard3/data

# Start config servers
echo "Starting config servers..."
mongod --config /home/taha/sharding_mongodb_project/mongodb-sharding/config/configsvr1.conf
mongod --config /home/taha/sharding_mongodb_project/mongodb-sharding/config/configsvr2.conf
mongod --config /home/taha/sharding_mongodb_project/mongodb-sharding/config/configsvr3.conf

# Wait for config servers to start
sleep 5

# Start shard servers
echo "Starting shard servers..."
mongod --config /home/taha/sharding_mongodb_project/mongodb-sharding/shard1/shardsvr1.conf
mongod --config /home/taha/sharding_mongodb_project/mongodb-sharding/shard2/shardsvr2.conf
mongod --config /home/taha/sharding_mongodb_project/mongodb-sharding/shard3/shardsvr3.conf

# Wait for shard servers to start
sleep 5

# Start mongos
echo "Starting mongos router..."
mongos --config /home/taha/sharding_mongodb_project/mongodb-sharding/mongos.conf

echo "MongoDB Sharded Cluster started successfully!"
echo "Connect to mongos at: mongodb://127.0.0.1:27017" 