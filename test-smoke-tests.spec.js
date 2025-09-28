const { test, expect } = require('@playwright/test');

test.describe('Smoke Tests', () => {
  test('Homepage loads correctly', async ({ page }) => {
    await page.goto('https://ecommerceapp-7268d--blue-kvsprspl.web.app  ');
    await expect(page).toHaveTitle(/Flutter Ecommerce App/);
    await page.waitForLoadState('networkidle');
  });

  test('Navigation works', async ({ page }) => {
    await page.goto('https://ecommerceapp-7268d--blue-kvsprspl.web.app  ');
    
    // Test navigation to different pages
    const catalogLink = page.locator('text=Catalog').first();
    if (await catalogLink.isVisible()) {
      await catalogLink.click();
      await page.waitForLoadState('networkidle');
    }
  });

  test('App is responsive', async ({ page }) => {
    await page.goto('https://ecommerceapp-7268d--blue-kvsprspl.web.app  ');
    
    // Test mobile viewport
    await page.setViewportSize({ width: 375, height: 667 });
    await page.waitForLoadState('networkidle');
    
    // Test desktop viewport
    await page.setViewportSize({ width: 1920, height: 1080 });
    await page.waitForLoadState('networkidle');
  });
});
