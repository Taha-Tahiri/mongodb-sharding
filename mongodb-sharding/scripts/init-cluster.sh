#!/bin/bash

# Script to initialize MongoDB sharded cluster
echo "Initializing MongoDB Sharded Cluster..."

# Initialize config server replica set
echo "Initializing config server replica set..."
mongosh --port 27019 --eval '
rs.initiate({
  _id: "configReplSet",
  configsvr: true,
  members: [
    { _id: 0, host: "127.0.0.1:27019" },
    { _id: 1, host: "127.0.0.1:27020" },
    { _id: 2, host: "127.0.0.1:27021" }
  ]
})
'

# Wait for config replica set to be ready
sleep 10

# Initialize shard1 replica set
echo "Initializing shard1 replica set..."
mongosh --port 27001 --eval '
rs.initiate({
  _id: "shard1ReplSet",
  members: [
    { _id: 0, host: "127.0.0.1:27001" }
  ]
})
'

# Initialize shard2 replica set
echo "Initializing shard2 replica set..."
mongosh --port 27002 --eval '
rs.initiate({
  _id: "shard2ReplSet",
  members: [
    { _id: 0, host: "127.0.0.1:27002" }
  ]
})
'

# Initialize shard3 replica set
echo "Initializing shard3 replica set..."
mongosh --port 27003 --eval '
rs.initiate({
  _id: "shard3ReplSet",
  members: [
    { _id: 0, host: "127.0.0.1:27003" }
  ]
})
'

# Wait for all replica sets to be ready
sleep 15

# Connect to mongos and add shards
echo "Adding shards to the cluster..."
mongosh --port 27017 --eval '
sh.addShard("shard1ReplSet/127.0.0.1:27001")
sh.addShard("shard2ReplSet/127.0.0.1:27002")
sh.addShard("shard3ReplSet/127.0.0.1:27003")
'

echo "MongoDB Sharded Cluster initialized successfully!" 