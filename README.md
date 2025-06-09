# Configuration d'un Cluster MongoDB Shardé

## Vue d'ensemble

Ce projet configure un cluster MongoDB shardé avec 3 shards (clusters) pour distribuer les données sur plusieurs serveurs. L'architecture comprend :

- **3 serveurs de configuration** : Stockent les métadonnées du cluster
- **3 serveurs de shards** : Stockent les données réelles
- **1 routeur mongos** : Point d'entrée pour les applications

## Démarrage Rapide

Si Docker est déjà installé et que vous voulez démarrer rapidement :

```bash
# 1. Aller dans le répertoire du projet
cd sharding_mongodb_project

# 2. Rendre les scripts exécutables
chmod +x *.sh

# 3. Démarrer les conteneurs
sudo docker compose up -d

# 4. Attendre 10 secondes puis initialiser le cluster
sleep 10
sudo ./docker-init-shard.sh

# 5. Créer la base de données et insérer des données
sudo ./docker-demo-shard.sh

# 6. Se connecter au cluster
sudo docker exec -it mongos mongosh

# Une fois connecté :
use mystore
db.products.find().limit(5)
sh.status()
```

## Prérequis et Installation

### Configuration Minimale Requise
- **OS** : Linux (Ubuntu/Debian recommandé), macOS, ou Windows avec WSL2
- **RAM** : Minimum 4 GB (8 GB recommandé)
- **Espace disque** : Minimum 10 GB disponible
- **Processeur** : 2 cores minimum (4 cores recommandé)

### Logiciels Requis

#### 1. Installation de Docker

**Sur Ubuntu/Debian :**
```bash
# Mettre à jour les paquets
sudo apt update
sudo apt upgrade -y

# Installer les dépendances
sudo apt install -y ca-certificates curl gnupg lsb-release

# Ajouter la clé GPG officielle de Docker
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Ajouter le repository Docker
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Installer Docker Engine
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Ajouter votre utilisateur au groupe docker
sudo usermod -aG docker $USER

# Redémarrer pour appliquer les changements
newgrp docker
```

**Sur macOS :**
```bash
# Installer Docker Desktop depuis
# https://www.docker.com/products/docker-desktop/
```

**Sur Windows (WSL2) :**
```bash
# 1. Installer WSL2 depuis PowerShell (en tant qu'admin) :
wsl --install

# 2. Installer Docker Desktop depuis :
# https://www.docker.com/products/docker-desktop/

# 3. Activer l'intégration WSL2 dans Docker Desktop
```

#### 2. Vérification de l'Installation

```bash
# Vérifier Docker
docker --version
# Devrait afficher : Docker version 20.x.x ou plus récent

# Vérifier Docker Compose
docker compose version
# Devrait afficher : Docker Compose version v2.x.x

# Tester Docker
docker run hello-world
```

## Architecture du Cluster

```
                    Application
                        |
                    mongos:27017
                        |
        +---------------+---------------+
        |               |               |
    Shard 1         Shard 2         Shard 3
    (27001)         (27002)         (27003)
        
    Config Servers: 27019, 27020, 27021
```

## Structure des Fichiers

```
mongodb-sharding/
├── config/              # Serveurs de configuration
│   ├── configsvr1.conf
│   ├── configsvr2.conf
│   └── configsvr3.conf
├── shard1/             # Premier shard
│   └── shardsvr1.conf
├── shard2/             # Deuxième shard
│   └── shardsvr2.conf
├── shard3/             # Troisième shard
│   └── shardsvr3.conf
├── mongos.conf         # Configuration du routeur
├── scripts/            # Scripts de gestion
│   ├── start-cluster.sh
│   ├── init-cluster.sh
│   ├── setup-sharded-collection.sh
│   └── stop-cluster.sh
└── logs/              # Fichiers de journalisation
```

## Guide d'Installation et Démarrage Complet

### Installation du Projet

#### 1. Cloner ou Copier le Projet

Si vous avez reçu ce dossier, placez-le simplement dans votre répertoire de travail :
```bash
cd ~
# Si vous avez un fichier zip
unzip sharding_mongodb_project.zip
cd sharding_mongodb_project
```

#### 2. Vérifier les Permissions des Scripts

```bash
# Rendre tous les scripts exécutables
chmod +x *.sh
```

### Démarrage du Cluster MongoDB Shardé

#### Étape 1 : Démarrer les Conteneurs Docker

```bash
# Démarrer tous les conteneurs en arrière-plan
sudo docker compose up -d
```

Cette commande va :
- Télécharger l'image MongoDB 7.0 si nécessaire
- Créer un réseau Docker pour la communication
- Démarrer 7 conteneurs (3 config, 3 shards, 1 mongos)

**Vérifier que tout est démarré :**
```bash
sudo docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

#### Étape 2 : Initialiser le Cluster

```bash
# Initialiser les replica sets et configurer le sharding
sudo ./docker-init-shard.sh
```

Ce script va :
- Initialiser le replica set de configuration
- Initialiser les 3 replica sets de shards
- Ajouter les shards au cluster

#### Étape 3 : Créer la Base de Données et Insérer des Données

```bash
# Exécuter le script de démonstration
sudo ./docker-demo-shard.sh
```

Ce script va :
- Créer la base de données `mystore`
- Créer la collection `products` shardée
- Insérer 1000 produits d'exemple
- Afficher des statistiques

### Utilisation du Cluster

#### Connexion au Cluster

```bash
# Se connecter au shell MongoDB via mongos
sudo docker exec -it mongos mongosh
```

#### Commandes MongoDB Essentielles

Une fois connecté au shell MongoDB :

```javascript
// Sélectionner la base de données
use mystore

// Afficher les collections
show collections

// Compter les documents
db.products.countDocuments()

// Voir des exemples de produits
db.products.find().limit(5).pretty()

// Vérifier le statut du sharding
sh.status()

// Voir la distribution des données
db.products.getShardDistribution()
```

### Exemples de Requêtes

#### 1. Requêtes de Base

```javascript
// Trouver tous les produits d'une catégorie
db.products.find({ category: "Electronics" })

// Trouver des produits par fourchette de prix
db.products.find({ price: { $gte: 100, $lte: 500 } })

// Trouver un produit spécifique
db.products.findOne({ product_id: 100 })
```

#### 2. Requêtes d'Agrégation

```javascript
// Nombre de produits par catégorie
db.products.aggregate([
    { $group: { _id: "$category", count: { $sum: 1 } } },
    { $sort: { count: -1 } }
])

// Prix moyen par catégorie
db.products.aggregate([
    { $group: { 
        _id: "$category", 
        avgPrice: { $avg: "$price" },
        minPrice: { $min: "$price" },
        maxPrice: { $max: "$price" }
    }},
    { $sort: { avgPrice: -1 } }
])

// Top 10 produits les plus chers
db.products.find().sort({ price: -1 }).limit(10)
```

#### 3. Insertions et Mises à Jour

```javascript
// Insérer un nouveau produit
db.products.insertOne({
    product_id: 9999,
    name: "Nouveau Produit",
    category: "Electronics",
    brand: "MaMarque",
    price: 299.99,
    stock: 50,
    rating: 4.5,
    created_at: new Date()
})

// Mettre à jour le stock d'un produit
db.products.updateOne(
    { product_id: 100 },
    { $inc: { stock: -5 } }
)

// Mettre à jour le prix de tous les produits d'une catégorie
db.products.updateMany(
    { category: "Books" },
    { $mul: { price: 0.9 } }  // Réduction de 10%
)
```

#### 4. Création de Commandes

```javascript
// Créer une nouvelle commande
db.orders.insertOne({
    order_id: "ORD-" + new Date().getTime(),
    product_id: 100,
    customer_id: "CUST-001",
    quantity: 2,
    price: 599.99,
    total: 1199.98,
    order_date: new Date(),
    status: "pending"
})

// Voir toutes les commandes
db.orders.find().pretty()
```

### Scripts Supplémentaires

#### Exécuter une Démonstration Interactive

```bash
# Pour plus d'exemples et de données
sudo ./docker-interactive-demo.sh
```

Ce script va :
- Insérer 5000 produits supplémentaires
- Effectuer des requêtes complexes
- Simuler des commandes
- Montrer les performances des requêtes

## Détails de Configuration

### Serveurs de Configuration

Les serveurs de configuration stockent les métadonnées du cluster :

- **Port 27019** : configsvr1
- **Port 27020** : configsvr2
- **Port 27021** : configsvr3

Configuration type (configsvr1.conf) :
```yaml
sharding:
  clusterRole: configsvr
replication:
  replSetName: configReplSet
net:
  port: 27019
  bindIp: 127.0.0.1
```

### Serveurs de Shards

Chaque shard est un replica set indépendant :

- **Shard 1** : Port 27001
- **Shard 2** : Port 27002
- **Shard 3** : Port 27003

Configuration type (shardsvr1.conf) :
```yaml
sharding:
  clusterRole: shardsvr
replication:
  replSetName: shard1ReplSet
net:
  port: 27001
  bindIp: 127.0.0.1
```

### Routeur Mongos

Le routeur mongos est le point d'entrée pour les applications :

- **Port** : 27017 (port MongoDB par défaut)
- **Config DB** : Connexion aux serveurs de configuration

## Base de Données et Collections

### Base de données : `mystore`

### Collection `products` (shardée)
Structure des documents :
```javascript
{
  product_id: Number,      // Partie de la clé de shard
  name: String,
  category: String,        // Partie de la clé de shard
  brand: String,
  price: Number,
  stock: Number,
  rating: Number,
  created_at: Date,
  warehouse: String,       // Optionnel
  tags: Array             // Optionnel
}
```

### Collection `orders` (non shardée)
Structure des documents :
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

### Stratégie de Sharding

- **Clé de shard** : `{ category: 1, product_id: 1 }` (composée)
- **Type** : Range sharding pour permettre des requêtes ciblées
- **Avantage** : Les requêtes par catégorie sont routées vers des shards spécifiques

## Commandes Utiles

### Se connecter au cluster
```bash
sudo docker exec -it mongos mongosh
```

### Vérifier le statut du sharding
```javascript
sh.status()
```

### Voir la distribution des chunks
```javascript
use mystore
db.products.getShardDistribution()
```

### Ajouter un nouveau shard
```javascript
sh.addShard("shard4ReplSet/127.0.0.1:27004")
```

### Activer le sharding sur une nouvelle base de données
```javascript
sh.enableSharding("nouvelle_db")
```

### Sharder une nouvelle collection
```javascript
sh.shardCollection("nouvelle_db.collection", { "cle": 1 })
```

## Gestion du Cluster

### Arrêter le Cluster

```bash
# Arrêter tous les conteneurs
sudo docker compose down

# Arrêter et supprimer les volumes (ATTENTION: supprime les données)
sudo docker compose down -v
```

### Redémarrer le Cluster

```bash
# Redémarrer tous les conteneurs
sudo docker compose restart

# Ou redémarrer un conteneur spécifique
sudo docker restart mongos
```

### Surveillance et Logs

```bash
# Voir les logs du routeur mongos
sudo docker logs mongos

# Suivre les logs en temps réel
sudo docker logs -f mongos

# Voir les logs d'un shard spécifique
sudo docker logs shard1

# Voir l'utilisation des ressources
sudo docker stats
```

## Dépannage

### Problèmes Courants et Solutions

#### 1. Docker n'est pas installé
```bash
# Vérifier si Docker est installé
docker --version

# Si non installé, suivre les instructions d'installation ci-dessus
```

#### 2. Permission denied sur Docker
```bash
# Ajouter l'utilisateur au groupe docker
sudo usermod -aG docker $USER

# Se reconnecter ou utiliser
newgrp docker

# Ou utiliser sudo devant toutes les commandes docker
```

#### 3. Les conteneurs ne démarrent pas
```bash
# Vérifier l'état des conteneurs
sudo docker ps -a

# Voir les logs d'erreur
sudo docker logs configsvr1

# Nettoyer et redémarrer
sudo docker compose down
sudo docker compose up -d
```

#### 4. Erreur "port already in use"
```bash
# Vérifier quel processus utilise le port 27017
sudo lsof -i :27017

# Tuer le processus si nécessaire
sudo kill -9 <PID>

# Ou changer le port dans docker-compose.yml
```

#### 5. Problèmes de connexion MongoDB
```bash
# Vérifier que mongos est accessible
sudo docker exec -it mongos mongosh --eval "print('Connected!')"

# Si erreur, attendre que l'initialisation soit complète
sleep 30
sudo ./docker-init-shard.sh
```

### Commandes de Diagnostic MongoDB

```javascript
// Dans le shell MongoDB
use mystore

// Vérifier l'état du cluster
sh.status()

// Voir les erreurs récentes
db.adminCommand({ getLog: "global" })

// Vérifier la réplication
rs.status()

// Voir les opérations en cours
db.currentOp()

// Statistiques détaillées
db.serverStatus()
```

## Avantages du Sharding

1. **Scalabilité horizontale** : Ajout facile de nouveaux shards
2. **Haute disponibilité** : Réplication dans chaque shard
3. **Performance** : Distribution de la charge entre les shards
4. **Capacité** : Dépassement des limites d'un seul serveur

## Considérations Importantes

1. **Choix de la clé de shard** : Crucial pour la performance
2. **Équilibrage** : MongoDB équilibre automatiquement les chunks
3. **Requêtes** : Les requêtes ciblées sont plus performantes
4. **Sauvegarde** : Nécessite une stratégie spécifique pour les clusters shardés

## Dépannage

### Le cluster ne démarre pas
- Vérifier que MongoDB est installé : `mongod --version`
- Vérifier les ports disponibles : `netstat -tlnp | grep 270`
- Consulter les logs dans `/mongodb-sharding/logs/`

### Erreurs de replica set
- Attendre que les replica sets soient complètement initialisés
- Vérifier la connectivité entre les membres

### Performance lente
- Vérifier la distribution des chunks : `sh.status()`
- Analyser les requêtes avec `explain()`
- Considérer l'ajout d'index appropriés

## Structure du Projet

```
sharding_mongodb_project/
├── docker-compose.yml           # Configuration Docker des conteneurs
├── docker-init-shard.sh        # Script d'initialisation du cluster
├── docker-demo-shard.sh        # Script de démonstration avec données
├── docker-interactive-demo.sh  # Démonstration interactive avancée
├── demo-queries.js            # Exemples de requêtes MongoDB
├── README.md                  # Ce fichier (documentation complète)
├── README-DOCKER.md           # Guide spécifique Docker
└── mongodb-sharding/          # Configuration MongoDB native (optionnel)
    ├── config/               # Configurations des serveurs de config
    ├── shard1/              # Configuration du shard 1
    ├── shard2/              # Configuration du shard 2
    ├── shard3/              # Configuration du shard 3
    └── scripts/             # Scripts pour MongoDB natif
```

## Commandes Récapitulatives

### Installation Complète sur une Nouvelle Machine

```bash
# 1. Installer Docker
sudo apt update && sudo apt install -y docker.io docker-compose-plugin
sudo usermod -aG docker $USER && newgrp docker

# 2. Get the project and run
cd ~/sharding_mongodb_project
chmod +x *.sh
sudo docker compose up -d
sleep 10
sudo ./docker-init-shard.sh
sudo ./docker-demo-shard.sh

# 3. Connect and use
sudo docker exec -it mongos mongosh
```

### Commandes Quotidiennes

```bash
# Démarrer le cluster
sudo docker compose up -d

# Arrêter le cluster
sudo docker compose down

# Se connecter à MongoDB
sudo docker exec -it mongos mongosh

# Voir les logs
sudo docker logs -f mongos

# Vérifier l'état
sudo docker ps
```

## Ressources Supplémentaires

- [Documentation MongoDB Sharding](https://docs.mongodb.com/manual/sharding/)
- [Meilleures pratiques de sharding](https://docs.mongodb.com/manual/core/sharding-shard-key/)
- [Monitoring des clusters shardés](https://docs.mongodb.com/manual/administration/monitoring/)
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/)

## Support

En cas de problème :
1. Vérifier les logs : `sudo docker logs [nom_conteneur]`
2. Vérifier l'état des conteneurs : `sudo docker ps -a`
3. Redémarrer le cluster : `sudo docker compose restart`
4. Réinitialiser complètement : `sudo docker compose down -v && sudo docker compose up -d` 