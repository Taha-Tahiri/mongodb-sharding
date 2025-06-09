#!/bin/bash

echo "=== MongoDB Sharded Cluster Demo ==="
echo ""

# Create sharded database and collection
echo "1. Creating sharded database and collection..."
docker exec -it mongos mongosh --eval '
// Enable sharding on the database
sh.enableSharding("mystore");

// Create collection and index
db = db.getSiblingDB("mystore");
db.createCollection("products");

// Create index on shard key
db.products.createIndex({ "category": 1, "product_id": 1 });

// Shard the collection using a compound shard key
sh.shardCollection("mystore.products", { "category": 1, "product_id": 1 });

print("Sharding enabled on mystore.products");
'

echo ""
echo "2. Inserting sample data..."
docker exec -it mongos mongosh --eval '
db = db.getSiblingDB("mystore");

// Insert products from different categories
const categories = ["Electronics", "Books", "Clothing", "Food", "Toys"];
const brands = ["BrandA", "BrandB", "BrandC", "BrandD", "BrandE"];

print("Inserting 1000 sample products...");
for (let i = 1; i <= 1000; i++) {
    db.products.insertOne({
        product_id: i,
        name: "Product " + i,
        category: categories[Math.floor(Math.random() * categories.length)],
        brand: brands[Math.floor(Math.random() * brands.length)],
        price: parseFloat((Math.random() * 1000).toFixed(2)),
        stock: Math.floor(Math.random() * 100) + 1,
        rating: parseFloat((Math.random() * 5).toFixed(1)),
        created_at: new Date()
    });
}
print("Insertion completed!");
'

echo ""
echo "3. Querying data examples..."
docker exec -it mongos mongosh --eval '
db = db.getSiblingDB("mystore");

print("\n--- Query 1: Count total products ---");
print("Total products: " + db.products.countDocuments());

print("\n--- Query 2: Products by category ---");
db.products.aggregate([
    { $group: { _id: "$category", count: { $sum: 1 } } },
    { $sort: { count: -1 } }
]).forEach(doc => print(doc._id + ": " + doc.count + " products"));

print("\n--- Query 3: Top 5 expensive products ---");
db.products.find().sort({ price: -1 }).limit(5).forEach(doc => 
    print(doc.name + " - $" + doc.price + " (" + doc.category + ")")
);

print("\n--- Query 4: Average price by category ---");
db.products.aggregate([
    { $group: { 
        _id: "$category", 
        avgPrice: { $avg: "$price" },
        count: { $sum: 1 }
    }},
    { $sort: { avgPrice: -1 } }
]).forEach(doc => 
    print(doc._id + ": $" + doc.avgPrice.toFixed(2) + " (avg of " + doc.count + " products)")
);

print("\n--- Query 5: Products with low stock (< 10) ---");
print("Low stock products: " + db.products.countDocuments({ stock: { $lt: 10 } }));
'

echo ""
echo "4. Checking shard distribution..."
docker exec -it mongos mongosh --eval '
db = db.getSiblingDB("mystore");

print("\n--- Shard Distribution ---");
db.products.getShardDistribution();

print("\n--- Sharding Status ---");
sh.status();
'

echo ""
echo "5. Performing targeted queries (using shard key)..."
docker exec -it mongos mongosh --eval '
db = db.getSiblingDB("mystore");

print("\n--- Targeted Query: Electronics products ---");
print("Electronics count: " + db.products.countDocuments({ category: "Electronics" }));

print("\n--- Targeted Query: Specific product ---");
const product = db.products.findOne({ category: "Electronics", product_id: 100 });
if (product) {
    print("Found: " + product.name + " - $" + product.price);
} else {
    print("Product not found");
}
'

echo ""
echo "=== Demo completed! ==="
echo ""
echo "You can connect to the cluster using:"
echo "docker exec -it mongos mongosh" 