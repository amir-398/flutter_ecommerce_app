#!/bin/bash

# Script pour obtenir dynamiquement les URLs des canaux Firebase Hosting
# Usage: ./scripts/get-channel-urls.sh

set -e

PROJECT_ID="ecommerceapp-7268d"

echo "🔍 Récupération des URLs des canaux Firebase Hosting..."
echo "=================================================="

# Fonction pour obtenir l'URL d'un canal
get_channel_url() {
    local channel_id=$1
    local url=$(firebase hosting:channel:list --project=$PROJECT_ID | grep "$channel_id" | awk '{print $3}')
    echo "$url"
}

# Obtenir les URLs des canaux
echo "📊 URLs des canaux:"
echo ""

# Canal live
LIVE_URL="https://$PROJECT_ID.web.app"
echo "🔴 Live: $LIVE_URL"

# Canal blue
BLUE_URL=$(get_channel_url "blue")
if [ -n "$BLUE_URL" ]; then
    echo "🔵 Blue: $BLUE_URL"
else
    echo "🔵 Blue: Canal non trouvé"
fi

# Canal green
GREEN_URL=$(get_channel_url "green")
if [ -n "$GREEN_URL" ]; then
    echo "🟢 Green: $GREEN_URL"
else
    echo "🟢 Green: Canal non trouvé"
fi

echo ""
echo "📋 Informations détaillées:"
firebase hosting:channel:list --project=$PROJECT_ID

echo ""
echo "✅ URLs récupérées avec succès"
