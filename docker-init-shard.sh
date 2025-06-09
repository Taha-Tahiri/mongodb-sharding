#!/bin/bash

echo "Waiting for MongoDB containers to start..."
sleep 10

echo "Initializing Config Server Replica Set..."
docker exec -it configsvr1 mongosh --port 27019 --eval '
rs.initiate({
  _id: "configReplSet",
  configsvr: true,
  members: [
    { _id: 0, host: "configsvr1:27019" },
    { _id: 1, host: "configsvr2:27019" },
    { _id: 2, host: "configsvr3:27019" }
  ]
})'

echo "Waiting for Config Server Replica Set to stabilize..."
sleep 10

echo "Initializing Shard 1 Replica Set..."
docker exec -it shard1 mongosh --port 27018 --eval '
rs.initiate({
  _id: "shard1ReplSet",
  members: [{ _id: 0, host: "shard1:27018" }]
})'

echo "Initializing Shard 2 Replica Set..."
docker exec -it shard2 mongosh --port 27018 --eval '
rs.initiate({
  _id: "shard2ReplSet",
  members: [{ _id: 0, host: "shard2:27018" }]
})'

echo "Initializing Shard 3 Replica Set..."
docker exec -it shard3 mongosh --port 27018 --eval '
rs.initiate({
  _id: "shard3ReplSet",
  members: [{ _id: 0, host: "shard3:27018" }]
})'

echo "Waiting for all Replica Sets to stabilize..."
sleep 15

echo "Adding shards to the cluster..."
docker exec -it mongos mongosh --eval '
sh.addShard("shard1ReplSet/shard1:27018");
sh.addShard("shard2ReplSet/shard2:27018");
sh.addShard("shard3ReplSet/shard3:27018");
'

echo "MongoDB Sharded Cluster initialized successfully!" 