#!/bin/bash

# Script to create a sample database and sharded collection
echo "Setting up sample sharded database and collection..."

mongosh --port 27017 <<EOF
// Enable sharding on the database
sh.enableSharding("ecommerce")

// Create the collection with a hashed shard key on user_id
use ecommerce
db.createCollection("orders")

// Create an index on the shard key
db.orders.createIndex({ "user_id": "hashed" })

// Shard the collection
sh.shardCollection("ecommerce.orders", { "user_id": "hashed" })

// Insert sample data
print("Inserting sample data...")
for (let i = 1; i <= 10000; i++) {
    db.orders.insertOne({
        order_id: i,
        user_id: Math.floor(Math.random() * 1000) + 1,
        product_name: "Product " + (Math.floor(Math.random() * 100) + 1),
        quantity: Math.floor(Math.random() * 10) + 1,
        price: parseFloat((Math.random() * 1000).toFixed(2)),
        order_date: new Date(2024, Math.floor(Math.random() * 12), Math.floor(Math.random() * 28) + 1),
        status: ["pending", "processing", "shipped", "delivered"][Math.floor(Math.random() * 4)]
    })
}

// Show distribution statistics
print("\nSharding statistics:")
sh.status()

// Show chunk distribution
print("\nChunk distribution for ecommerce.orders:")
db.orders.getShardDistribution()

print("\nSample sharded collection created successfully!")
EOF

echo "Setup complete!" 