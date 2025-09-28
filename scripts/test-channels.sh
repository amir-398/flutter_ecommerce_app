#!/bin/bash

# Script de test rapide pour vérifier que tous les canaux fonctionnent
# Usage: ./scripts/test-channels.sh

set -e

PROJECT_ID="ecommerceapp-7268d"

echo "🧪 Test des canaux Firebase Hosting"
echo "=================================================="
echo ""

# Fonction pour tester une URL
test_url() {
    local url=$1
    local name=$2
    
    echo -n "Testing $name: "
    
    local status_code=$(curl -s -o /dev/null -w "%{http_code}" "$url")
    local response_time=$(curl -s -o /dev/null -w "%{time_total}" "$url")
    
    if [ "$status_code" = "200" ]; then
        echo "✅ OK (${response_time}s)"
        return 0
    else
        echo "❌ FAILED (HTTP $status_code)"
        return 1
    fi
}

# Tester les canaux
echo "📊 Test des canaux:"
echo ""

test_url "https://$PROJECT_ID.web.app" "Live"
test_url "https://ecommerceapp-7268d--blue-kvsprspl.web.app" "Blue Preview"
test_url "https://ecommerceapp-7268d--green-mg6s1mfo.web.app" "Green Preview"

echo ""
echo "🔍 Vérification du contenu:"

# Vérifier que les pages contiennent du contenu Flutter
echo -n "Live content check: "
if curl -s "https://$PROJECT_ID.web.app" | grep -q "flutter"; then
    echo "✅ Flutter content detected"
else
    echo "⚠️  No Flutter content detected"
fi

echo -n "Blue content check: "
if curl -s "https://ecommerceapp-7268d--blue-kvsprspl.web.app" | grep -q "flutter"; then
    echo "✅ Flutter content detected"
else
    echo "⚠️  No Flutter content detected"
fi

echo -n "Green content check: "
if curl -s "https://ecommerceapp-7268d--green-mg6s1mfo.web.app" | grep -q "flutter"; then
    echo "✅ Flutter content detected"
else
    echo "⚠️  No Flutter content detected"
fi

echo ""
echo "✅ Tests terminés"
echo ""
echo "💡 Si tous les tests passent, votre stratégie Blue-Green est opérationnelle !"
