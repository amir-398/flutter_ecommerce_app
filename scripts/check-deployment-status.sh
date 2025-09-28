#!/bin/bash

# Script de vérification du statut des déploiements
# Usage: ./scripts/check-deployment-status.sh

set -e

PROJECT_ID="ecommerceapp-7268d"
BASE_URL="https://$PROJECT_ID.web.app"

echo "🔍 Vérification du statut des déploiements..."
echo "=" .repeat(50)

# Fonction pour vérifier une URL
check_url() {
    local url=$1
    local name=$2
    
    echo -n "Checking $name: "
    
    if curl -f -s -o /dev/null -w "%{http_code}" "$url" | grep -q "200"; then
        echo "✅ OK"
        return 0
    else
        echo "❌ FAILED"
        return 1
    fi
}

# Fonction pour mesurer le temps de réponse
measure_response_time() {
    local url=$1
    local name=$2
    
    echo -n "Response time for $name: "
    
    local response_time=$(curl -o /dev/null -s -w "%{time_total}" "$url")
    echo "${response_time}s"
    
    # Vérifier si le temps de réponse est acceptable (< 3 secondes)
    if (( $(echo "$response_time < 3" | bc -l) )); then
        echo "  ✅ Response time is good"
    else
        echo "  ⚠️  Response time is slow"
    fi
}

# Vérifier les canaux
echo "📊 Statut des canaux:"
echo ""

check_url "$BASE_URL" "Live"
check_url "https://blue--$PROJECT_ID.web.app" "Blue Preview"
check_url "https://green--$PROJECT_ID.web.app" "Green Preview"

echo ""
echo "⏱️  Temps de réponse:"
echo ""

measure_response_time "$BASE_URL" "Live"
measure_response_time "https://blue--$PROJECT_ID.web.app" "Blue Preview"
measure_response_time "https://green--$PROJECT_ID.web.app" "Green Preview"

echo ""
echo "🔧 Informations Firebase:"

# Vérifier si Firebase CLI est disponible
if command -v firebase &> /dev/null; then
    echo "Firebase CLI: ✅ Installed"
    
    # Lister les canaux
    echo ""
    echo "📋 Canaux Firebase Hosting:"
    firebase hosting:channel:list --project=$PROJECT_ID 2>/dev/null || echo "  ⚠️  Impossible de récupérer la liste des canaux"
else
    echo "Firebase CLI: ❌ Not installed"
fi

echo ""
echo "📈 Recommandations:"

# Vérifier les performances
live_time=$(curl -o /dev/null -s -w "%{time_total}" "$BASE_URL")
if (( $(echo "$live_time > 3" | bc -l) )); then
    echo "  ⚠️  Le site live est lent (${live_time}s). Considérez l'optimisation."
fi

# Vérifier la disponibilité
if ! curl -f -s "$BASE_URL" > /dev/null; then
    echo "  🚨 Le site live n'est pas accessible. Rollback d'urgence recommandé."
fi

echo ""
echo "✅ Vérification terminée"
