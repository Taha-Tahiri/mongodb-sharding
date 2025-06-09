// MongoDB Sharding Demo Queries
// Run these queries by connecting to mongos:
// sudo docker exec -it mongos mongosh

// Switch to the mystore database
use mystore

// 1. Check current collection statistics
print("\n=== Collection Statistics ===");
db.products.stats();

// 2. Count documents by category
print("\n=== Product Count by Category ===");
db.products.aggregate([
    { $group: { _id: "$category", count: { $sum: 1 } } },
    { $sort: { count: -1 } }
]).forEach(doc => print(doc._id + ": " + doc.count));

// 3. Find products with specific criteria
print("\n=== High-Value Electronics (>$800) ===");
db.products.find({ 
    category: "Electronics", 
    price: { $gt: 800 } 
}).limit(5).forEach(doc => 
    print(doc.name + " - $" + doc.price)
);

// 4. Update a product's stock
print("\n=== Updating Product Stock ===");
let result = db.products.updateOne(
    { product_id: 100 },
    { $inc: { stock: -5 } }
);
print("Modified: " + result.modifiedCount);

// 5. Create a new order
print("\n=== Creating New Order ===");
db.orders.insertOne({
    order_id: "ORD-" + new Date().getTime(),
    product_id: 100,
    customer_id: "CUST-123",
    quantity: 2,
    order_date: new Date(),
    status: "pending"
});
print("Order created successfully!");

// 6. Aggregation pipeline - Sales analysis
print("\n=== Top 5 Brands by Product Count ===");
db.products.aggregate([
    { $group: { 
        _id: "$brand", 
        productCount: { $sum: 1 },
        avgPrice: { $avg: "$price" }
    }},
    { $sort: { productCount: -1 } },
    { $limit: 5 }
]).forEach(doc => 
    print(doc._id + ": " + doc.productCount + " products, avg price: $" + doc.avgPrice.toFixed(2))
);

// 7. Check shard distribution
print("\n=== Shard Distribution ===");
db.products.getShardDistribution();

// 8. Explain a query to see if it's targeted or scatter-gather
print("\n=== Query Explanation ===");
print("Targeted query (using shard key):");
db.products.find({ category: "Electronics", product_id: 100 }).explain("executionStats");

print("\nScatter-gather query (not using shard key):");
db.products.find({ price: { $gt: 500 } }).explain("executionStats"); 