# Configuration MongoDB Shardé avec Docker

## Résumé de l'Installation

J'ai créé un cluster MongoDB shardé fonctionnel utilisant Docker Compose avec :

- **3 serveurs de configuration** (Config Servers)
- **3 serveurs de shards** (Shard Servers) 
- **1 routeur mongos** (point d'entrée)
- **Base de données `mystore`** avec 6000 produits
- **Collection `orders`** avec des commandes d'exemple

## Démarrage Rapide

### 1. Démarrer le cluster
```bash
sudo docker compose up -d
```

### 2. Initialiser les replica sets et shards
```bash
sudo ./docker-init-shard.sh
```

### 3. Exécuter la démo (créer DB et insérer des données)
```bash
sudo ./docker-demo-shard.sh
```

## Connexion au Cluster

Pour vous connecter au cluster MongoDB :
```bash
sudo docker exec -it mongos mongosh
```

## Exemples de Requêtes

### Compter les produits par catégorie
```javascript
use mystore
db.products.aggregate([
    { $group: { _id: "$category", count: { $sum: 1 } } },
    { $sort: { count: -1 } }
])
```

### Trouver des produits spécifiques
```javascript
// Produits électroniques coûteux
db.products.find({ 
    category: "Electronics", 
    price: { $gt: 800 } 
}).limit(5)
```

### Créer une commande
```javascript
db.orders.insertOne({
    order_id: "ORD-" + new Date().getTime(),
    product_id: 100,
    customer_id: "CUST-123",
    quantity: 2,
    price: 599.99,
    order_date: new Date(),
    status: "pending"
})
```

### Vérifier la distribution des shards
```javascript
db.products.getShardDistribution()
sh.status()
```

## Structure des Collections

### Collection `products`
```javascript
{
    product_id: Number,      // Partie de la clé de shard
    name: String,
    category: String,        // Partie de la clé de shard  
    brand: String,
    price: Number,
    stock: Number,
    rating: Number,
    created_at: Date
}
```

### Collection `orders`
```javascript
{
    order_id: String,
    product_id: Number,
    product_name: String,
    category: String,
    quantity: Number,
    price: Number,
    customer_id: String,
    order_date: Date,
    status: String
}
```

## Opérations Avancées

### Requête ciblée (utilise la clé de shard)
```javascript
// Cette requête est routée vers un shard spécifique
db.products.find({ 
    category: "Electronics", 
    product_id: { $gte: 100, $lte: 200 } 
})
```

### Requête scatter-gather (n'utilise pas la clé de shard)
```javascript
// Cette requête doit interroger tous les shards
db.products.find({ 
    price: { $gte: 500, $lte: 600 } 
})
```

### Pipeline d'agrégation
```javascript
// Analyse des ventes par marque
db.products.aggregate([
    { $group: { 
        _id: "$brand", 
        avgPrice: { $avg: "$price" },
        totalProducts: { $sum: 1 }
    }},
    { $sort: { avgPrice: -1 } },
    { $limit: 10 }
])
```

## Gestion du Cluster

### Arrêter le cluster
```bash
sudo docker compose down
```

### Voir les logs
```bash
# Logs du routeur mongos
sudo docker logs mongos

# Logs d'un shard spécifique
sudo docker logs shard1
```

### Redémarrer le cluster
```bash
sudo docker compose restart
```

## Fichiers Importants

- `docker-compose.yml` : Configuration des conteneurs
- `docker-init-shard.sh` : Script d'initialisation
- `docker-demo-shard.sh` : Script de démonstration
- `demo-queries.js` : Exemples de requêtes MongoDB

## Résultats Actuels

Le cluster contient actuellement :
- **6000 produits** répartis en 5 catégories
- **10+ commandes** d'exemple
- Données distribuées sur **3 shards**
- Clé de shard composée : `{ category: 1, product_id: 1 }`

## Performance

- Les requêtes utilisant la clé de shard sont **ciblées** (rapides)
- Les requêtes sans clé de shard sont **scatter-gather** (plus lentes)
- Le balancer MongoDB distribue automatiquement les chunks

## Pour Aller Plus Loin

Vous pouvez :
1. Ajouter plus de shards
2. Créer d'autres collections shardées
3. Tester différentes stratégies de clés de shard
4. Monitorer la performance avec `db.currentOp()`
5. Configurer l'authentification et la sécurité 