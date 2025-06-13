# Documentation de Configuration du Cluster MongoDB Shardé

## Configuration Actuelle du Cluster

Le cluster MongoDB se compose de :
- 3 Serveurs de Configuration (configsvr1, configsvr2, configsvr3)
- 3 Serveurs Shard (shard1, shard2, shard3)
- 1 Routeur Mongos

## Configuration des Replica Sets

Cette cluster possède des replica sets configurés. Chaque shard est configuré comme un replica set :
- shard1ReplSet (shard1)
- shard2ReplSet (shard2)
- shard3ReplSet (shard3)

## Distribution des Documents

Les documents sont actuellement stockés dans shard2 pour les raisons suivantes :

1. La base de données `boutique_en_ligne` n'est pas shardée (partitioned: false)
2. Le shard principal de la base de données est défini sur `shard2ReplSet`
3. Lorsqu'une base de données n'est pas shardée, toutes ses collections sont stockées sur le shard principal

Ceci est évident dans la sortie de sh.status() :
```json
{
    "database": {
        "_id": "boutique_en_ligne",
        "primary": "shard2ReplSet",
        "partitioned": false
    }
}
```

## Activation du Sharding

Pour distribuer les données sur tous les shards, les étapes suivantes sont nécessaires :

1. Activation du sharding pour la base de données :
```javascript
sh.enableSharding("boutique_en_ligne")
```

2. Configuration de la clé de sharding pour les collections :
```javascript
sh.shardCollection("boutique_en_ligne.commandes", { "_id": 1 })
```

## Fonctionnement des Replica Sets

Chaque shard dans le cluster fonctionne comme un replica set, offrant :

1. **Haute Disponibilité** : Chaque shard peut avoir plusieurs copies des données
2. **Redondance des Données** : Les données sont répliquées à travers les membres du replica set
3. **Basculement Automatique** : Si le nœud principal échoue, un nœud secondaire devient automatiquement principal

## Limitations Actuelles

1. **Stockage sur un Seul Shard** : Toutes les données sont actuellement stockées dans shard2 car :
   - La base de données n'est pas shardée
   - Aucune clé de sharding n'est définie pour les collections
   - Le balancer ne distribue pas activement les données

2. **Configuration des Replica Sets** : Bien que les replica sets soient configurés, ils ne sont peut-être pas complètement initialisés avec plusieurs membres, ce qui implique :
   - Redondance limitée
   - Pas de basculement automatique
   - Point de défaillance unique pour chaque shard

## Recommandations d'Optimisation

1. Activation du sharding pour la base de données
2. Sélection de clés de sharding appropriées pour les collections
3. Initialisation des replica sets avec plusieurs membres pour une meilleure redondance
4. Surveillance du balancer pour assurer une distribution équitable des données
5. Ajout de membres supplémentaires à chaque replica set pour une meilleure disponibilité 