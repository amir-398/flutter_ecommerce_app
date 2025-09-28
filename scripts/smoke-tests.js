/**
 * Script de smoke tests pour l'application Flutter Ecommerce
 * Utilise Playwright pour tester les fonctionnalités critiques
 */

const { chromium } = require("playwright");

class SmokeTester {
  constructor(baseUrl) {
    this.baseUrl = baseUrl;
    this.results = {
      passed: 0,
      failed: 0,
      tests: [],
    };
  }

  async runTest(name, testFn) {
    console.log(`🧪 Running: ${name}`);
    try {
      await testFn();
      this.results.passed++;
      this.results.tests.push({ name, status: "PASSED" });
      console.log(`✅ PASSED: ${name}`);
    } catch (error) {
      this.results.failed++;
      this.results.tests.push({ name, status: "FAILED", error: error.message });
      console.log(`❌ FAILED: ${name} - ${error.message}`);
    }
  }

  async testPageLoad() {
    const browser = await chromium.launch();
    const page = await browser.newPage();

    try {
      await page.goto(this.baseUrl, { waitUntil: "networkidle" });

      // Vérifier que la page se charge
      const title = await page.title();
      if (!title || title === "") {
        throw new Error("Page title is empty");
      }

      // Vérifier qu'il n'y a pas d'erreurs JavaScript critiques
      const errors = [];
      page.on("console", (msg) => {
        if (msg.type() === "error") {
          errors.push(msg.text());
        }
      });

      await page.waitForTimeout(2000);

      // Filtrer les erreurs non critiques
      const criticalErrors = errors.filter(
        (error) =>
          !error.includes("favicon") &&
          !error.includes("404") &&
          !error.includes("CORS")
      );

      if (criticalErrors.length > 0) {
        throw new Error(
          `Critical JavaScript errors: ${criticalErrors.join(", ")}`
        );
      }
    } finally {
      await browser.close();
    }
  }

  async testNavigation() {
    const browser = await chromium.launch();
    const page = await browser.newPage();

    try {
      await page.goto(this.baseUrl, { waitUntil: "networkidle" });

      // Chercher des éléments de navigation
      const navSelectors = [
        "nav",
        '[role="navigation"]',
        ".navigation",
        ".navbar",
        ".menu",
      ];

      let navFound = false;
      for (const selector of navSelectors) {
        const nav = await page.locator(selector).first();
        if (await nav.isVisible()) {
          navFound = true;
          break;
        }
      }

      if (!navFound) {
        throw new Error("No navigation elements found");
      }
    } finally {
      await browser.close();
    }
  }

  async testResponsiveness() {
    const browser = await chromium.launch();
    const page = await browser.newPage();

    try {
      const viewports = [
        { width: 375, height: 667, name: "Mobile" },
        { width: 768, height: 1024, name: "Tablet" },
        { width: 1920, height: 1080, name: "Desktop" },
      ];

      for (const viewport of viewports) {
        await page.setViewportSize({
          width: viewport.width,
          height: viewport.height,
        });
        await page.goto(this.baseUrl, { waitUntil: "networkidle" });

        // Vérifier que la page est visible
        const body = await page.locator("body");
        if (!(await body.isVisible())) {
          throw new Error(
            `Page not visible on ${viewport.name} (${viewport.width}x${viewport.height})`
          );
        }
      }
    } finally {
      await browser.close();
    }
  }

  async testPerformance() {
    const browser = await chromium.launch();
    const page = await browser.newPage();

    try {
      const startTime = Date.now();
      await page.goto(this.baseUrl, { waitUntil: "networkidle" });
      const loadTime = Date.now() - startTime;

      console.log(`📊 Page load time: ${loadTime}ms`);

      // La page doit se charger en moins de 5 secondes
      if (loadTime > 5000) {
        throw new Error(
          `Page load time too slow: ${loadTime}ms (expected < 5000ms)`
        );
      }
    } finally {
      await browser.close();
    }
  }

  async testFlutterApp() {
    const browser = await chromium.launch();
    const page = await browser.newPage();

    try {
      await page.goto(this.baseUrl, { waitUntil: "networkidle" });

      // Vérifier que Flutter est chargé
      const flutterLoaded = await page.evaluate(() => {
        return (
          window.flutter !== undefined ||
          document.querySelector("flt-glass-pane") !== null ||
          document.querySelector("flt-scene-host") !== null
        );
      });

      if (!flutterLoaded) {
        throw new Error("Flutter app not properly loaded");
      }

      // Attendre que l'application Flutter soit prête
      await page.waitForTimeout(3000);
    } finally {
      await browser.close();
    }
  }

  async runAllTests() {
    console.log(`🚀 Starting smoke tests for: ${this.baseUrl}`);
    console.log("=".repeat(50));

    await this.runTest("Page Load", () => this.testPageLoad());
    await this.runTest("Navigation", () => this.testNavigation());
    await this.runTest("Responsiveness", () => this.testResponsiveness());
    await this.runTest("Performance", () => this.testPerformance());
    await this.runTest("Flutter App", () => this.testFlutterApp());

    console.log("=".repeat(50));
    console.log(
      `📊 Results: ${this.results.passed} passed, ${this.results.failed} failed`
    );

    if (this.results.failed > 0) {
      console.log("\n❌ Failed tests:");
      this.results.tests
        .filter((test) => test.status === "FAILED")
        .forEach((test) => console.log(`   - ${test.name}: ${test.error}`));
    }

    return this.results.failed === 0;
  }
}

// Fonction principale
async function main() {
  const baseUrl = process.argv[2];

  if (!baseUrl) {
    console.error("❌ Usage: node smoke-tests.js <URL>");
    console.error(
      "Example: node smoke-tests.js https://blue--ecommerceapp-7268d.web.app"
    );
    process.exit(1);
  }

  const tester = new SmokeTester(baseUrl);
  const success = await tester.runAllTests();

  process.exit(success ? 0 : 1);
}

// Exécuter si appelé directement
if (require.main === module) {
  main().catch((error) => {
    console.error("❌ Smoke tests failed:", error);
    process.exit(1);
  });
}

module.exports = SmokeTester;
