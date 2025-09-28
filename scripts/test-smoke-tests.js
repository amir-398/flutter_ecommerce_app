/**
 * Script de test local pour les smoke tests
 * Usage: node scripts/test-smoke-tests.js
 */

const { chromium } = require('playwright');

async function testSmokeTests() {
  console.log('🧪 Test des smoke tests avec les vraies URLs...');
  
  // URLs des canaux (obtenues depuis firebase hosting:channel:list)
  const channels = {
    live: 'https://ecommerceapp-7268d.web.app',
    blue: 'https://ecommerceapp-7268d--blue-kvsprspl.web.app',
    green: 'https://ecommerceapp-7268d--green-mg6s1mfo.web.app'
  };

  const browser = await chromium.launch();
  
  for (const [channelName, url] of Object.entries(channels)) {
    console.log(`\n🔍 Testing ${channelName} channel: ${url}`);
    
    try {
      const page = await browser.newPage();
      
      // Test de chargement de page
      await page.goto(url, { waitUntil: 'networkidle' });
      
      // Vérifier le titre
      const title = await page.title();
      console.log(`  ✅ Page loaded: ${title}`);
      
      // Vérifier qu'il n'y a pas d'erreurs critiques
      const errors = [];
      page.on('console', msg => {
        if (msg.type() === 'error') {
          errors.push(msg.text());
        }
      });
      
      await page.waitForTimeout(2000);
      
      const criticalErrors = errors.filter(error => 
        !error.includes('favicon') && 
        !error.includes('404') &&
        !error.includes('CORS')
      );
      
      if (criticalErrors.length > 0) {
        console.log(`  ⚠️  Console errors: ${criticalErrors.join(', ')}`);
      } else {
        console.log(`  ✅ No critical console errors`);
      }
      
      // Test de performance
      const startTime = Date.now();
      await page.goto(url, { waitUntil: 'networkidle' });
      const loadTime = Date.now() - startTime;
      console.log(`  📊 Load time: ${loadTime}ms`);
      
      await page.close();
      
    } catch (error) {
      console.log(`  ❌ Error testing ${channelName}: ${error.message}`);
    }
  }
  
  await browser.close();
  console.log('\n✅ Smoke tests completed!');
}

// Exécuter les tests
testSmokeTests().catch(error => {
  console.error('❌ Smoke tests failed:', error);
  process.exit(1);
});
