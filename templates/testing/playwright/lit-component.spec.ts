import { test, expect } from '@playwright/test';

/**
 * Lit Component Testing Template
 * 
 * This template provides examples for testing Lit components with Playwright.
 * Adapt the selectors and expectations to match your specific components.
 */

test.describe('Lit Component Tests', () => {
  test.beforeEach(async ({ page }) => {
    // Navigate to your component page
    await page.goto('/');
    
    // Wait for the component to be defined and rendered
    await page.waitForFunction(() => {
      return customElements.get('my-component') !== undefined;
    });
  });

  test('should render component with default properties', async ({ page }) => {
    // Test that the component renders
    const component = page.locator('my-component');
    await expect(component).toBeVisible();
    
    // Test default content
    await expect(component).toContainText('Default content');
    
    // Test shadow DOM content (if your component uses shadow DOM)
    const shadowContent = component.locator('>> text=Shadow content');
    await expect(shadowContent).toBeVisible();
  });

  test('should update when properties change', async ({ page }) => {
    const component = page.locator('my-component');
    
    // Change a property using JavaScript
    await page.evaluate(() => {
      const element = document.querySelector('my-component');
      if (element) {
        element.setAttribute('title', 'Updated Title');
      }
    });
    
    // Verify the change is reflected
    await expect(component).toContainText('Updated Title');
  });

  test('should handle user interactions', async ({ page }) => {
    const component = page.locator('my-component');
    const button = component.locator('button');
    
    // Click a button in the component
    await button.click();
    
    // Verify the interaction result
    await expect(component.locator('.result')).toContainText('Clicked!');
  });

  test('should dispatch custom events', async ({ page }) => {
    const component = page.locator('my-component');
    
    // Listen for custom events
    const eventPromise = page.evaluate(() => {
      return new Promise((resolve) => {
        document.addEventListener('my-custom-event', (event) => {
          resolve(event.detail);
        }, { once: true });
      });
    });
    
    // Trigger an action that dispatches the event
    await component.locator('button[data-action="trigger-event"]').click();
    
    // Verify the event was dispatched with correct data
    const eventDetail = await eventPromise;
    expect(eventDetail).toEqual({ action: 'triggered', timestamp: expect.any(Number) });
  });

  test('should be accessible', async ({ page }) => {
    const component = page.locator('my-component');
    
    // Test keyboard navigation
    await page.keyboard.press('Tab');
    await expect(component.locator('button:first-child')).toBeFocused();
    
    // Test ARIA attributes
    await expect(component).toHaveAttribute('role', 'button');
    await expect(component).toHaveAttribute('aria-label', expect.stringContaining('component'));
    
    // Test screen reader announcements
    const announcement = component.locator('[aria-live]');
    await expect(announcement).toHaveText('Status updated');
  });

  test('should work with different viewport sizes', async ({ page }) => {
    const component = page.locator('my-component');
    
    // Test mobile viewport
    await page.setViewportSize({ width: 375, height: 667 });
    await expect(component).toHaveClass(/mobile/);
    
    // Test desktop viewport
    await page.setViewportSize({ width: 1200, height: 800 });
    await expect(component).toHaveClass(/desktop/);
  });

  test('should handle error states gracefully', async ({ page }) => {
    const component = page.locator('my-component');
    
    // Simulate an error condition
    await page.evaluate(() => {
      const element = document.querySelector('my-component');
      if (element) {
        element.setAttribute('error', 'true');
      }
    });
    
    // Verify error handling
    await expect(component.locator('.error-message')).toBeVisible();
    await expect(component.locator('.error-message')).toContainText('Something went wrong');
  });

  test('should load asynchronously', async ({ page }) => {
    const component = page.locator('my-async-component');
    
    // Initially shows loading state
    await expect(component.locator('.loading')).toBeVisible();
    
    // Wait for async content to load
    await expect(component.locator('.content')).toBeVisible({ timeout: 5000 });
    await expect(component.locator('.loading')).not.toBeVisible();
  });

  test('should handle forms correctly', async ({ page }) => {
    const form = page.locator('my-form-component form');
    const input = form.locator('input[name="username"]');
    const submitButton = form.locator('button[type="submit"]');
    
    // Fill form
    await input.fill('testuser');
    
    // Submit form
    await submitButton.click();
    
    // Verify form submission
    await expect(page.locator('.success-message')).toBeVisible();
    await expect(page.locator('.success-message')).toContainText('Form submitted successfully');
  });

  test('should persist state across navigation', async ({ page }) => {
    const component = page.locator('my-stateful-component');
    
    // Set some state
    await component.locator('button[data-action="increment"]').click();
    await expect(component.locator('.counter')).toContainText('1');
    
    // Navigate away and back
    await page.goto('/other-page');
    await page.goBack();
    
    // Verify state is preserved (if expected)
    await expect(component.locator('.counter')).toContainText('1');
  });
});

test.describe('Lit Component Integration Tests', () => {
  test('should work with multiple components', async ({ page }) => {
    await page.goto('/multi-component-page');
    
    const componentA = page.locator('component-a');
    const componentB = page.locator('component-b');
    
    // Test component interaction
    await componentA.locator('button').click();
    await expect(componentB.locator('.updated')).toBeVisible();
  });

  test('should work with web components polyfills', async ({ page }) => {
    // Test in browsers that might need polyfills
    const component = page.locator('my-component');
    await expect(component).toBeVisible();
    
    // Verify polyfills loaded correctly
    const polyfillsLoaded = await page.evaluate(() => {
      return window.WebComponents && window.WebComponents.ready;
    });
    
    expect(polyfillsLoaded).toBeTruthy();
  });
});

// Visual regression testing (requires setup)
test.describe('Visual Tests', () => {
  test('should match component screenshots', async ({ page }) => {
    await page.goto('/component-showcase');
    
    const component = page.locator('my-component');
    
    // Take screenshot of component
    await expect(component).toHaveScreenshot('my-component-default.png');
    
    // Test different states
    await component.hover();
    await expect(component).toHaveScreenshot('my-component-hover.png');
  });
});