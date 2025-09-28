#!/bin/bash

# Script de configuration des canaux Firebase Hosting pour Blue-Green deployment
# Usage: ./scripts/setup-firebase-channels.sh

set -e

echo "🚀 Configuration des canaux Firebase Hosting pour Blue-Green deployment..."

# Vérifier que Firebase CLI est installé
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI n'est pas installé. Installez-le avec:"
    echo "npm install -g firebase-tools"
    exit 1
fi

# Vérifier que l'utilisateur est connecté
if ! firebase projects:list &> /dev/null; then
    echo "❌ Vous n'êtes pas connecté à Firebase. Connectez-vous avec:"
    echo "firebase login"
    exit 1
fi

PROJECT_ID="ecommerceapp-7268d"

echo "📋 Configuration du projet: $PROJECT_ID"

# Créer les canaux blue et green
echo "🔵 Création du canal 'blue'..."
firebase hosting:channel:deploy blue --project=$PROJECT_ID --only=hosting:blue || echo "⚠️ Canal blue existe peut-être déjà"

echo "🟢 Création du canal 'green'..."
firebase hosting:channel:deploy green --project=$PROJECT_ID --only=hosting:green || echo "⚠️ Canal green existe peut-être déjà"

# Lister les canaux existants
echo "📊 Canaux existants:"
firebase hosting:channel:list --project=$PROJECT_ID

echo "✅ Configuration terminée!"
echo ""
echo "📝 Prochaines étapes:"
echo "1. Configurez les secrets GitHub Actions:"
echo "   - FIREBASE_SERVICE_ACCOUNT_ECOMMERCEAPP_7268D"
echo "   - FIREBASE_TOKEN"
echo ""
echo "2. Testez le déploiement avec:"
echo "   git push origin main"
echo ""
echo "3. Pour promouvoir manuellement vers live:"
echo "   - Allez dans Actions > Promote to Live"
echo "   - Sélectionnez le canal source (blue ou green)"
echo "   - Tapez 'PROMOTE' pour confirmer"
echo ""
echo "🔗 URLs des canaux:"
echo "   - Live: https://$PROJECT_ID.web.app"
echo "   - Blue: https://blue--$PROJECT_ID.web.app"
echo "   - Green: https://green--$PROJECT_ID.web.app"
