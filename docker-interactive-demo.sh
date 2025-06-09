#!/bin/bash

echo "=== Interactive MongoDB Sharding Demo ==="
echo ""

# Function to execute MongoDB commands
mongo_exec() {
    sudo docker exec -it mongos mongosh --eval "$1"
}

# 1. Show current shard status
echo "1. Current Shard Status:"
mongo_exec '
db = db.getSiblingDB("mystore");
print("\nTotal products in database: " + db.products.countDocuments());
print("\nShard distribution:");
db.products.getShardDistribution();
'

# 2. Insert more targeted data
echo -e "\n2. Inserting 5000 more products with specific categories..."
mongo_exec '
db = db.getSiblingDB("mystore");
const categories = ["Electronics", "Books", "Clothing", "Food", "Toys"];

// Insert products in batches for better performance
let bulk = db.products.initializeUnorderedBulkOp();
let batchCount = 0;

for (let i = 1001; i <= 6000; i++) {
    bulk.insert({
        product_id: i,
        name: "Product " + i,
        category: categories[i % 5], // Even distribution across categories
        brand: "Brand" + (i % 10),
        price: parseFloat((Math.random() * 1000).toFixed(2)),
        stock: Math.floor(Math.random() * 100) + 1,
        rating: parseFloat((Math.random() * 5).toFixed(1)),
        created_at: new Date(),
        warehouse: "Warehouse" + (i % 3),
        tags: ["tag" + (i % 7), "tag" + (i % 11)]
    });
    
    batchCount++;
    
    // Execute batch every 1000 documents
    if (batchCount === 1000) {
        bulk.execute();
        bulk = db.products.initializeUnorderedBulkOp();
        batchCount = 0;
    }
}

// Execute remaining documents
if (batchCount > 0) {
    bulk.execute();
}

print("Insertion completed! Total products now: " + db.products.countDocuments());
'

# 3. Complex aggregation queries
echo -e "\n3. Running complex aggregation queries..."
mongo_exec '
db = db.getSiblingDB("mystore");

print("\n--- Top brands by average rating ---");
db.products.aggregate([
    { $group: { 
        _id: "$brand", 
        avgRating: { $avg: "$rating" },
        productCount: { $sum: 1 }
    }},
    { $sort: { avgRating: -1 } },
    { $limit: 5 }
]).forEach(doc => 
    print(doc._id + ": " + doc.avgRating.toFixed(2) + " stars (" + doc.productCount + " products)")
);

print("\n--- Warehouse inventory distribution ---");
db.products.aggregate([
    { $group: { 
        _id: "$warehouse", 
        totalStock: { $sum: "$stock" },
        avgPrice: { $avg: "$price" },
        productCount: { $sum: 1 }
    }},
    { $sort: { totalStock: -1 } }
]).forEach(doc => 
    print(doc._id + ": " + doc.totalStock + " units, $" + doc.avgPrice.toFixed(2) + " avg price (" + doc.productCount + " products)")
);
'

# 4. Targeted vs Scatter-Gather queries comparison
echo -e "\n4. Query Performance Comparison..."
mongo_exec '
db = db.getSiblingDB("mystore");

// Targeted query (uses shard key)
print("\n--- Targeted Query (using shard key) ---");
let start = new Date();
let count = db.products.find({ category: "Electronics", product_id: { $gte: 1000, $lte: 2000 } }).count();
let end = new Date();
print("Found " + count + " Electronics products in range 1000-2000");
print("Query time: " + (end - start) + "ms");

// Scatter-gather query (does not use shard key)
print("\n--- Scatter-Gather Query (not using shard key) ---");
start = new Date();
count = db.products.find({ price: { $gte: 500, $lte: 600 } }).count();
end = new Date();
print("Found " + count + " products in price range $500-$600");
print("Query time: " + (end - start) + "ms");
'

# 5. Real-time monitoring
echo -e "\n5. Real-time Order Processing Simulation..."
mongo_exec '
db = db.getSiblingDB("mystore");

// Create orders collection if not exists
db.createCollection("orders");

// Simulate order processing
print("\nProcessing 100 orders...");
for (let i = 1; i <= 100; i++) {
    // Pick a random product
    let randomProduct = db.products.aggregate([{ $sample: { size: 1 } }]).next();
    
    // Create order
    db.orders.insertOne({
        order_id: "ORD-" + Date.now() + "-" + i,
        product_id: randomProduct.product_id,
        product_name: randomProduct.name,
        category: randomProduct.category,
        quantity: Math.floor(Math.random() * 5) + 1,
        unit_price: randomProduct.price,
        total_price: randomProduct.price * (Math.floor(Math.random() * 5) + 1),
        customer_id: "CUST-" + Math.floor(Math.random() * 1000),
        order_date: new Date(),
        status: "pending"
    });
    
    // Update product stock
    db.products.updateOne(
        { product_id: randomProduct.product_id },
        { $inc: { stock: -(Math.floor(Math.random() * 5) + 1) } }
    );
}

print("\nOrder Summary:");
db.orders.aggregate([
    { $group: { 
        _id: "$category", 
        totalOrders: { $sum: 1 },
        totalRevenue: { $sum: "$total_price" }
    }},
    { $sort: { totalRevenue: -1 } }
]).forEach(doc => 
    print(doc._id + ": " + doc.totalOrders + " orders, $" + doc.totalRevenue.toFixed(2) + " revenue")
);
'

# 6. Show final shard distribution
echo -e "\n6. Final Shard Distribution:"
mongo_exec '
db = db.getSiblingDB("mystore");
print("\nTotal documents: " + db.products.countDocuments());
print("\nDetailed shard statistics:");
sh.status();
'

echo -e "\n=== Demo Complete! ==="
echo "You can connect directly to explore more:"
echo "sudo docker exec -it mongos mongosh" 