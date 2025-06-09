#!/bin/bash

# Script de configuration rapide du cluster MongoDB shardé

echo "=== Configuration Rapide du Cluster MongoDB Shardé ==="
echo ""

# Étape 1: Démarrer le cluster
echo "Étape 1: Démarrage du cluster..."
./start-cluster.sh

# Attendre que tous les services soient démarrés
echo "Attente du démarrage complet des services..."
sleep 10

# Étape 2: Initialiser les replica sets et ajouter les shards
echo ""
echo "Étape 2: Initialisation des replica sets et ajout des shards..."
./init-cluster.sh

# Attendre que l'initialisation soit complète
echo "Attente de l'initialisation complète..."
sleep 10

# Étape 3: Créer la base de données et la collection shardée
echo ""
echo "Étape 3: Création de la base de données et de la collection shardée..."
./setup-sharded-collection.sh

echo ""
echo "=== Configuration Terminée! ==="
echo ""
echo "Le cluster MongoDB shardé est maintenant opérationnel!"
echo "Connexion: mongosh --port 27017"
echo ""
echo "Pour arrêter le cluster: ./stop-cluster.sh" 