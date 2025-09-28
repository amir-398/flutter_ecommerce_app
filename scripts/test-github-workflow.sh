#!/bin/bash

# Script de test pour simuler le workflow GitHub Actions
# Usage: ./scripts/test-github-workflow.sh

set -e

echo "🧪 Test du workflow GitHub Actions Blue-Green"
echo "=================================================="

# Simuler les variables d'environnement GitHub Actions
export FIREBASE_PROJECT_ID="ecommerceapp-7268d"

echo "📋 Variables d'environnement:"
echo "  FIREBASE_PROJECT_ID: $FIREBASE_PROJECT_ID"
echo ""

# Simuler la détermination du canal
echo "🔍 Détermination du canal de déploiement..."
CHANNEL="blue"  # Simuler le choix automatique
echo "  Canal choisi: $CHANNEL"
echo ""

# Simuler l'obtention de l'URL du canal
echo "🔗 Récupération de l'URL du canal..."
CHANNEL_URL=$(firebase hosting:channel:list --project=$FIREBASE_PROJECT_ID | grep "$CHANNEL" | sed 's/.*│ *\(https[^│]*\) *│.*/\1/')
echo "  URL du canal: $CHANNEL_URL"
echo ""

# Simuler la génération du script de smoke tests
echo "📝 Génération du script de smoke tests..."
cat > test-smoke-tests.spec.js << EOF
const { test, expect } = require('@playwright/test');

test.describe('Smoke Tests', () => {
  test('Homepage loads correctly', async ({ page }) => {
    await page.goto('$CHANNEL_URL');
    await expect(page).toHaveTitle(/Flutter Ecommerce App/);
    await page.waitForLoadState('networkidle');
  });

  test('Navigation works', async ({ page }) => {
    await page.goto('$CHANNEL_URL');
    
    // Test navigation to different pages
    const catalogLink = page.locator('text=Catalog').first();
    if (await catalogLink.isVisible()) {
      await catalogLink.click();
      await page.waitForLoadState('networkidle');
    }
  });

  test('App is responsive', async ({ page }) => {
    await page.goto('$CHANNEL_URL');
    
    // Test mobile viewport
    await page.setViewportSize({ width: 375, height: 667 });
    await page.waitForLoadState('networkidle');
    
    // Test desktop viewport
    await page.setViewportSize({ width: 1920, height: 1080 });
    await page.waitForLoadState('networkidle');
  });
});
EOF

echo "✅ Script de smoke tests généré avec l'URL: $CHANNEL_URL"
echo ""

# Vérifier que l'URL n'est pas vide
if [ -z "$CHANNEL_URL" ]; then
    echo "❌ ERREUR: L'URL du canal est vide!"
    echo "   Cela expliquerait l'erreur 'Cannot navigate to invalid URL'"
    exit 1
else
    echo "✅ L'URL du canal est correctement définie"
fi

echo ""
echo "📊 Résumé du test:"
echo "  - Canal: $CHANNEL"
echo "  - URL: $CHANNEL_URL"
echo "  - Script généré: test-smoke-tests.spec.js"
echo ""
echo "✅ Test du workflow terminé avec succès!"
echo ""
echo "💡 Pour tester les smoke tests, exécutez:"
echo "   npm init -y && npm install -D @playwright/test"
echo "   npx playwright install --with-deps"
echo "   npx playwright test test-smoke-tests.spec.js"
