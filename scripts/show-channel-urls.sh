#!/bin/bash

# Script simple pour afficher les URLs des canaux Firebase Hosting
# Usage: ./scripts/show-channel-urls.sh

PROJECT_ID="ecommerceapp-7268d"

echo "🔍 URLs des canaux Firebase Hosting"
echo "=================================================="
echo ""

echo "🔴 Live (Production):"
echo "   https://$PROJECT_ID.web.app"
echo ""

echo "🔵 Blue (Preview):"
echo "   https://ecommerceapp-7268d--blue-kvsprspl.web.app"
echo ""

echo "🟢 Green (Preview):"
echo "   https://ecommerceapp-7268d--green-mg6s1mfo.web.app"
echo ""

echo "📋 Liste complète des canaux:"
firebase hosting:channel:list --project=$PROJECT_ID

echo ""
echo "✅ URLs affichées avec succès"
echo ""
echo "💡 Note: Les URLs des canaux preview changent à chaque déploiement."
echo "   Utilisez 'firebase hosting:channel:list' pour obtenir les URLs actuelles."
