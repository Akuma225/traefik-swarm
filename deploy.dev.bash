#!/bin/bash

set -e  # Arrête le script en cas d'erreur

# Extraire l'environnement du nom du fichier
SCRIPT_NAME=$(basename "$0")
ENV=$(echo $SCRIPT_NAME | cut -d'.' -f2)

if [ -z "$ENV" ]; then
    echo "Erreur: L'environnement n'est pas défini"
    exit 1
fi

echo "Environnement détecté: ${ENV}"

# Charger les variables d'environnement depuis le fichier .env
echo "waiting: Chargement des variables d'environnement..."
if [ ! -f ".env.${ENV}" ]; then
    echo "Erreur: Le fichier .env.${ENV} n'existe pas"
    exit 1
fi

# Charger les variables d'environnement
set -a # automatically export all variables
source ".env.${ENV}"
set +a
echo "success: Variables d'environnement chargées avec succès"

# Définir le nom du stack
STACK_NAME="traefik-${ENV}"
SERVICE_NAME="${STACK_NAME}_traefik"

# Mettre à jour l'image
echo "waiting: Mise à jour de l'image..."
docker pull ${IMAGE}
echo "success: Mise à jour de l'image réussie"

# Supprimer le service existant
echo "waiting: Suppression du service existant..."
docker service rm ${SERVICE_NAME} 2>/dev/null || true
echo "success: Suppression du service existant réussie"

# Déployer le stack
echo "waiting: Déploiement du stack ${STACK_NAME}..."
docker stack deploy -c docker-compose.yml ${STACK_NAME}
echo "success: Déploiement du stack ${STACK_NAME} réussie"

# Forcer la mise à jour du service
echo "waiting: Mise à jour forcée du service..."
docker service update --force ${SERVICE_NAME}
echo "success: Mise à jour forcée du service réussie"

# Afficher l'état des services
echo "waiting: Affichage des services..."
docker service ps ${SERVICE_NAME}
echo "success: Déploiement terminé"