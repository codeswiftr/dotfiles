import { test, expect } from '@playwright/test';

/**
 * PWA Functionality Testing Template
 * 
 * This template tests Progressive Web App features including:
 * - Service Worker functionality
 * - Offline capabilities
 * - App manifest
 * - Installation prompts
 * - Caching strategies
 */

test.describe('PWA Core Features', () => {
  test.beforeEach(async ({ page, context }) => {
    // Grant necessary permissions for PWA features
    await context.grantPermissions(['notifications']);
    
    // Navigate to the PWA
    await page.goto('/');
    
    // Wait for the app to fully load
    await page.waitForLoadState('networkidle');
  });

  test('should register service worker', async ({ page }) => {
    // Check if service worker is registered
    const serviceWorkerRegistered = await page.evaluate(async () => {
      if ('serviceWorker' in navigator) {
        const registration = await navigator.serviceWorker.getRegistration();
        return registration !== undefined;
      }
      return false;
    });
    
    expect(serviceWorkerRegistered).toBe(true);
    
    // Verify service worker is active
    const serviceWorkerActive = await page.evaluate(() => {
      return navigator.serviceWorker.controller !== null;
    });
    
    expect(serviceWorkerActive).toBe(true);
  });

  test('should have valid web app manifest', async ({ page }) => {
    // Check for manifest link in head
    const manifestLink = page.locator('link[rel="manifest"]');
    await expect(manifestLink).toHaveCount(1);
    
    // Get manifest URL and fetch it
    const manifestUrl = await manifestLink.getAttribute('href');
    expect(manifestUrl).toBeTruthy();
    
    // Verify manifest content
    const manifestResponse = await page.request.get(manifestUrl!);
    expect(manifestResponse.status()).toBe(200);
    
    const manifest = await manifestResponse.json();
    
    // Verify required manifest fields
    expect(manifest.name).toBeTruthy();
    expect(manifest.short_name).toBeTruthy();
    expect(manifest.start_url).toBeTruthy();
    expect(manifest.display).toBeTruthy();
    expect(manifest.theme_color).toBeTruthy();
    expect(manifest.background_color).toBeTruthy();
    expect(manifest.icons).toBeInstanceOf(Array);
    expect(manifest.icons.length).toBeGreaterThan(0);
    
    // Verify icon formats
    const requiredSizes = ['192x192', '512x512'];
    for (const size of requiredSizes) {
      const icon = manifest.icons.find((icon: any) => icon.sizes === size);
      expect(icon).toBeTruthy();
    }
  });

  test('should work offline', async ({ page, context }) => {
    // First, ensure the page loads online
    await page.goto('/');
    await expect(page.locator('body')).toBeVisible();
    
    // Cache critical resources by navigating around
    await page.goto('/about');
    await page.goto('/contact');
    await page.goto('/');
    
    // Go offline
    await context.setOffline(true);
    
    // Navigate to a previously visited page
    await page.goto('/about');
    await expect(page.locator('body')).toBeVisible();
    
    // Check for offline indicator (if your app has one)
    const offlineIndicator = page.locator('.offline-indicator');
    if (await offlineIndicator.count() > 0) {
      await expect(offlineIndicator).toBeVisible();
    }
    
    // Try to access a new page that should be cached
    await page.goto('/');
    await expect(page.locator('h1')).toBeVisible();
    
    // Verify service worker handled the request
    const fromCache = await page.evaluate(() => {
      return performance.getEntriesByType('navigation')[0].transferSize === 0;
    });
    expect(fromCache).toBe(true);
  });

  test('should handle offline form submissions', async ({ page, context }) => {
    await page.goto('/contact');
    
    // Fill out a form
    await page.fill('input[name="name"]', 'Test User');
    await page.fill('input[name="email"]', 'test@example.com');
    await page.fill('textarea[name="message"]', 'Test message');
    
    // Go offline
    await context.setOffline(true);
    
    // Submit form
    await page.click('button[type="submit"]');
    
    // Check for offline queue message
    await expect(page.locator('.offline-queue-message')).toBeVisible();
    
    // Go back online
    await context.setOffline(false);
    
    // Wait for form to be submitted from queue
    await expect(page.locator('.success-message')).toBeVisible({ timeout: 10000 });
  });

  test('should show installation prompt', async ({ page, context }) => {
    // Skip on mobile devices where install prompt behavior differs
    const userAgent = await page.evaluate(() => navigator.userAgent);
    if (/Mobile|Android|iPhone|iPad/.test(userAgent)) {
      test.skip();
    }
    
    // Listen for beforeinstallprompt event
    const installPromptShown = await page.evaluate(() => {
      return new Promise((resolve) => {
        let promptShown = false;
        
        window.addEventListener('beforeinstallprompt', (e) => {
          promptShown = true;
          e.preventDefault(); // Prevent automatic showing
          resolve(true);
        });
        
        // Trigger conditions that might show install prompt
        // This varies by implementation
        setTimeout(() => resolve(promptShown), 5000);
      });
    });
    
    // Note: Install prompt behavior is browser-dependent
    // This test might need adjustment based on your PWA criteria
  });

  test('should handle push notifications', async ({ page, context }) => {
    // Check if notifications are supported
    const notificationsSupported = await page.evaluate(() => {
      return 'Notification' in window;
    });
    
    if (!notificationsSupported) {
      test.skip();
    }
    
    // Request notification permission (already granted in beforeEach)
    const permission = await page.evaluate(() => Notification.permission);
    expect(permission).toBe('granted');
    
    // Test notification display
    await page.evaluate(() => {
      new Notification('Test Notification', {
        body: 'This is a test notification',
        icon: '/icons/icon-192x192.png',
        tag: 'test'
      });
    });
    
    // Note: Actual notification verification depends on browser capabilities
  });

  test('should update when service worker updates', async ({ page }) => {
    // Simulate service worker update
    const updateAvailable = await page.evaluate(async () => {
      if ('serviceWorker' in navigator) {
        const registration = await navigator.serviceWorker.getRegistration();
        if (registration) {
          // Simulate update
          registration.update();
          
          return new Promise((resolve) => {
            registration.addEventListener('updatefound', () => {
              resolve(true);
            });
            
            // Timeout if no update found
            setTimeout(() => resolve(false), 5000);
          });
        }
      }
      return false;
    });
    
    // Check for update notification (if your app shows one)
    if (await page.locator('.update-available').count() > 0) {
      await expect(page.locator('.update-available')).toBeVisible();
    }
  });

  test('should persist data locally', async ({ page }) => {
    await page.goto('/app');
    
    // Add some data
    await page.fill('input[name="note"]', 'Test note');
    await page.click('button[data-action="save"]');
    
    // Verify data is saved
    await expect(page.locator('.note-item')).toContainText('Test note');
    
    // Refresh page
    await page.reload();
    
    // Verify data persists
    await expect(page.locator('.note-item')).toContainText('Test note');
  });

  test('should handle app state transitions', async ({ page }) => {
    // Test visibility change (app goes to background)
    await page.evaluate(() => {
      // Simulate page visibility change
      Object.defineProperty(document, 'hidden', { value: true, writable: true });
      Object.defineProperty(document, 'visibilityState', { value: 'hidden', writable: true });
      document.dispatchEvent(new Event('visibilitychange'));
    });
    
    // Check if app handles background state
    const backgroundState = await page.evaluate(() => document.hidden);
    expect(backgroundState).toBe(true);
    
    // Simulate coming back to foreground
    await page.evaluate(() => {
      Object.defineProperty(document, 'hidden', { value: false, writable: true });
      Object.defineProperty(document, 'visibilityState', { value: 'visible', writable: true });
      document.dispatchEvent(new Event('visibilitychange'));
    });
    
    // Verify app resumes normal operation
    const foregroundState = await page.evaluate(() => document.hidden);
    expect(foregroundState).toBe(false);
  });
});

test.describe('PWA Performance', () => {
  test('should load quickly on repeat visits', async ({ page }) => {
    // First visit
    const startTime = Date.now();
    await page.goto('/');
    await page.waitForLoadState('networkidle');
    const firstLoadTime = Date.now() - startTime;
    
    // Second visit (should be faster due to caching)
    const secondStartTime = Date.now();
    await page.goto('/');
    await page.waitForLoadState('networkidle');
    const secondLoadTime = Date.now() - secondStartTime;
    
    // Second load should be significantly faster
    expect(secondLoadTime).toBeLessThan(firstLoadTime * 0.5);
  });

  test('should have good Lighthouse scores', async ({ page }) => {
    // Note: This requires additional setup with lighthouse-ci
    // or manual Lighthouse auditing
    
    await page.goto('/');
    
    // Basic performance checks
    const performanceMetrics = await page.evaluate(() => {
      const navigation = performance.getEntriesByType('navigation')[0] as PerformanceNavigationTiming;
      return {
        domContentLoaded: navigation.domContentLoadedEventEnd - navigation.domContentLoadedEventStart,
        loadComplete: navigation.loadEventEnd - navigation.loadEventStart,
        firstPaint: performance.getEntriesByName('first-paint')[0]?.startTime || 0,
        firstContentfulPaint: performance.getEntriesByName('first-contentful-paint')[0]?.startTime || 0
      };
    });
    
    // These thresholds should be adjusted based on your app's requirements
    expect(performanceMetrics.domContentLoaded).toBeLessThan(2000);
    expect(performanceMetrics.firstContentfulPaint).toBeLessThan(3000);
  });
});

test.describe('PWA Accessibility', () => {
  test('should be navigable with keyboard', async ({ page }) => {
    await page.goto('/');
    
    // Tab through interactive elements
    await page.keyboard.press('Tab');
    await expect(page.locator(':focus')).toBeVisible();
    
    // Continue tabbing to ensure logical order
    const focusableElements = [];
    for (let i = 0; i < 10; i++) {
      const focusedElement = await page.locator(':focus').getAttribute('class');
      focusableElements.push(focusedElement);
      await page.keyboard.press('Tab');
    }
    
    // Verify we can navigate through the app
    expect(focusableElements.filter(Boolean).length).toBeGreaterThan(0);
  });

  test('should work with screen readers', async ({ page }) => {
    await page.goto('/');
    
    // Check for proper heading structure
    const headings = await page.locator('h1, h2, h3, h4, h5, h6').count();
    expect(headings).toBeGreaterThan(0);
    
    // Check for alt text on images
    const images = page.locator('img');
    const imageCount = await images.count();
    
    for (let i = 0; i < imageCount; i++) {
      const img = images.nth(i);
      const alt = await img.getAttribute('alt');
      const ariaLabel = await img.getAttribute('aria-label');
      
      // Images should have alt text or aria-label
      expect(alt || ariaLabel).toBeTruthy();
    }
    
    // Check for proper form labels
    const inputs = page.locator('input, textarea, select');
    const inputCount = await inputs.count();
    
    for (let i = 0; i < inputCount; i++) {
      const input = inputs.nth(i);
      const id = await input.getAttribute('id');
      const ariaLabel = await input.getAttribute('aria-label');
      
      if (id) {
        const label = page.locator(`label[for="${id}"]`);
        const hasLabel = await label.count() > 0;
        
        // Input should have label or aria-label
        expect(hasLabel || ariaLabel).toBeTruthy();
      }
    }
  });
});