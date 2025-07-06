import http from 'k6/http';
import { check, sleep, group } from 'k6';
import { Rate, Trend, Counter } from 'k6/metrics';

/**
 * k6 Load Testing Template for FastAPI Applications
 * 
 * This template provides comprehensive load testing scenarios including:
 * - Basic load testing
 * - Stress testing
 * - Spike testing
 * - Authentication flows
 * - API endpoint testing
 */

// Custom metrics
const errorRate = new Rate('error_rate');
const responseTime = new Trend('response_time');
const requestCount = new Counter('request_count');

// Configuration
const BASE_URL = __ENV.BASE_URL || 'http://localhost:8000';
const USERNAME = __ENV.USERNAME || 'testuser@example.com';
const PASSWORD = __ENV.PASSWORD || 'testpassword';

// Load testing scenarios
export const options = {
  scenarios: {
    // Basic load test
    load_test: {
      executor: 'ramping-vus',
      startVUs: 1,
      stages: [
        { duration: '2m', target: 10 },   // Ramp up to 10 users
        { duration: '5m', target: 10 },   // Stay at 10 users
        { duration: '2m', target: 0 },    // Ramp down to 0 users
      ],
      exec: 'loadTest',
    },
    
    // Stress test
    stress_test: {
      executor: 'ramping-vus',
      startVUs: 1,
      stages: [
        { duration: '2m', target: 20 },   // Ramp up to 20 users
        { duration: '5m', target: 20 },   // Stay at 20 users
        { duration: '2m', target: 50 },   // Ramp up to 50 users
        { duration: '5m', target: 50 },   // Stay at 50 users
        { duration: '2m', target: 0 },    // Ramp down to 0 users
      ],
      exec: 'stressTest',
    },
    
    // Spike test
    spike_test: {
      executor: 'ramping-vus',
      startVUs: 1,
      stages: [
        { duration: '10s', target: 1 },   // Normal load
        { duration: '1m', target: 100 },  // Spike to 100 users
        { duration: '10s', target: 1 },   // Return to normal
      ],
      exec: 'spikeTest',
    },
    
    // API endpoint test
    api_test: {
      executor: 'constant-vus',
      vus: 5,
      duration: '5m',
      exec: 'apiTest',
    },
  },
  
  thresholds: {
    http_req_duration: ['p(95)<500'], // 95% of requests should be below 500ms
    http_req_failed: ['rate<0.1'],    // Error rate should be below 10%
    error_rate: ['rate<0.1'],
    response_time: ['p(95)<500'],
  },
};

// Setup function (runs once)
export function setup() {
  console.log('🚀 Starting load tests...');
  
  // Health check
  const healthResponse = http.get(`${BASE_URL}/health`);
  if (healthResponse.status !== 200) {
    throw new Error(`Health check failed: ${healthResponse.status}`);
  }
  
  console.log('✅ Health check passed');
  
  // Authenticate and get token (if your API requires auth)
  const authResponse = http.post(`${BASE_URL}/auth/login`, JSON.stringify({
    username: USERNAME,
    password: PASSWORD,
  }), {
    headers: { 'Content-Type': 'application/json' },
  });
  
  let authToken = null;
  if (authResponse.status === 200) {
    authToken = JSON.parse(authResponse.body).access_token;
    console.log('✅ Authentication successful');
  } else {
    console.log('⚠️  Authentication failed, running without auth');
  }
  
  return { authToken };
}

// Load test scenario
export function loadTest(data) {
  group('Load Test', () => {
    // Test basic endpoints
    testHealthEndpoint();
    testRootEndpoint();
    
    if (data.authToken) {
      testProtectedEndpoints(data.authToken);
    }
    
    sleep(1);
  });
}

// Stress test scenario
export function stressTest(data) {
  group('Stress Test', () => {
    // More intensive testing
    testHealthEndpoint();
    testRootEndpoint();
    testApiEndpoints(data.authToken);
    
    // Shorter sleep time for more intensive load
    sleep(0.5);
  });
}

// Spike test scenario
export function spikeTest(data) {
  group('Spike Test', () => {
    // Quick burst of requests
    testHealthEndpoint();
    testRootEndpoint();
    
    // No sleep for maximum load
  });
}

// API functionality test
export function apiTest(data) {
  group('API Functionality Test', () => {
    testCRUDOperations(data.authToken);
    sleep(2);
  });
}

// Individual test functions
function testHealthEndpoint() {
  const response = http.get(`${BASE_URL}/health`);
  
  const success = check(response, {
    'Health check status is 200': (r) => r.status === 200,
    'Health check response time < 100ms': (r) => r.timings.duration < 100,
    'Health check response contains status': (r) => r.json('status') === 'healthy',
  });
  
  errorRate.add(!success);
  responseTime.add(response.timings.duration);
  requestCount.add(1);
}

function testRootEndpoint() {
  const response = http.get(`${BASE_URL}/`);
  
  const success = check(response, {
    'Root endpoint status is 200': (r) => r.status === 200,
    'Root endpoint response time < 200ms': (r) => r.timings.duration < 200,
  });
  
  errorRate.add(!success);
  responseTime.add(response.timings.duration);
  requestCount.add(1);
}

function testProtectedEndpoints(authToken) {
  if (!authToken) return;
  
  const headers = {
    'Authorization': `Bearer ${authToken}`,
    'Content-Type': 'application/json',
  };
  
  const response = http.get(`${BASE_URL}/users/me`, { headers });
  
  const success = check(response, {
    'Protected endpoint status is 200': (r) => r.status === 200,
    'Protected endpoint response time < 300ms': (r) => r.timings.duration < 300,
  });
  
  errorRate.add(!success);
  responseTime.add(response.timings.duration);
  requestCount.add(1);
}

function testApiEndpoints(authToken) {
  const headers = authToken ? {
    'Authorization': `Bearer ${authToken}`,
    'Content-Type': 'application/json',
  } : {
    'Content-Type': 'application/json',
  };
  
  // Test GET endpoints
  group('GET Endpoints', () => {
    const endpoints = ['/items', '/users', '/categories'];
    
    endpoints.forEach(endpoint => {
      const response = http.get(`${BASE_URL}${endpoint}`, { headers });
      
      check(response, {
        [`${endpoint} status is 200 or 401`]: (r) => [200, 401].includes(r.status),
        [`${endpoint} response time < 500ms`]: (r) => r.timings.duration < 500,
      });
      
      requestCount.add(1);
    });
  });
  
  // Test POST endpoints
  group('POST Endpoints', () => {
    const itemData = {
      title: `Test Item ${Math.random()}`,
      description: 'Load test item',
    };
    
    const response = http.post(`${BASE_URL}/items/`, JSON.stringify(itemData), { headers });
    
    check(response, {
      'Create item status is 200 or 401': (r) => [200, 201, 401].includes(r.status),
      'Create item response time < 1000ms': (r) => r.timings.duration < 1000,
    });
    
    requestCount.add(1);
  });
}

function testCRUDOperations(authToken) {
  if (!authToken) {
    console.log('⚠️  Skipping CRUD tests - no auth token');
    return;
  }
  
  const headers = {
    'Authorization': `Bearer ${authToken}`,
    'Content-Type': 'application/json',
  };
  
  group('CRUD Operations', () => {
    // Create
    const createData = {
      title: `CRUD Test Item ${Date.now()}`,
      description: 'Testing CRUD operations',
    };
    
    const createResponse = http.post(`${BASE_URL}/items/`, JSON.stringify(createData), { headers });
    
    const createSuccess = check(createResponse, {
      'Create operation status is 201': (r) => r.status === 201,
      'Create response contains ID': (r) => r.json('id') !== undefined,
    });
    
    if (createSuccess && createResponse.json('id')) {
      const itemId = createResponse.json('id');
      
      // Read
      const readResponse = http.get(`${BASE_URL}/items/${itemId}`, { headers });
      check(readResponse, {
        'Read operation status is 200': (r) => r.status === 200,
        'Read response contains correct title': (r) => r.json('title') === createData.title,
      });
      
      // Update
      const updateData = {
        title: `Updated ${createData.title}`,
        description: 'Updated description',
      };
      
      const updateResponse = http.put(`${BASE_URL}/items/${itemId}`, JSON.stringify(updateData), { headers });
      check(updateResponse, {
        'Update operation status is 200': (r) => r.status === 200,
      });
      
      // Delete
      const deleteResponse = http.del(`${BASE_URL}/items/${itemId}`, null, { headers });
      check(deleteResponse, {
        'Delete operation status is 204': (r) => r.status === 204,
      });
    }
    
    requestCount.add(4); // 4 operations
  });
}

// Teardown function (runs once at the end)
export function teardown(data) {
  console.log('🏁 Load tests completed');
  console.log(`📊 Total requests: ${requestCount.count}`);
}

// Helper functions for custom scenarios
export function customScenario() {
  // You can create custom test scenarios here
  // Example: testing specific user journeys, complex workflows, etc.
  
  group('Custom Scenario', () => {
    // Simulate user registration
    const userData = {
      email: `user${Date.now()}@example.com`,
      password: 'testpassword123',
      username: `user${Date.now()}`,
    };
    
    const registerResponse = http.post(`${BASE_URL}/auth/register`, JSON.stringify(userData), {
      headers: { 'Content-Type': 'application/json' },
    });
    
    check(registerResponse, {
      'User registration successful': (r) => [200, 201].includes(r.status),
    });
    
    // Simulate user login
    const loginResponse = http.post(`${BASE_URL}/auth/login`, JSON.stringify({
      username: userData.email,
      password: userData.password,
    }), {
      headers: { 'Content-Type': 'application/json' },
    });
    
    check(loginResponse, {
      'User login successful': (r) => r.status === 200,
    });
    
    // Continue with authenticated actions...
  });
}

// Error handling
export function handleSummary(data) {
  return {
    'load-test-results.json': JSON.stringify(data, null, 2),
    'load-test-summary.html': generateHTMLReport(data),
  };
}

function generateHTMLReport(data) {
  const html = `
<!DOCTYPE html>
<html>
<head>
    <title>Load Test Results</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .metric { margin: 10px 0; padding: 10px; border: 1px solid #ddd; }
        .pass { background-color: #d4edda; }
        .fail { background-color: #f8d7da; }
    </style>
</head>
<body>
    <h1>Load Test Results</h1>
    <div class="metric">
        <h3>HTTP Request Duration</h3>
        <p>Average: ${data.metrics.http_req_duration.values.avg.toFixed(2)}ms</p>
        <p>95th Percentile: ${data.metrics.http_req_duration.values['p(95)'].toFixed(2)}ms</p>
    </div>
    <div class="metric">
        <h3>HTTP Request Failed Rate</h3>
        <p>Rate: ${(data.metrics.http_req_failed.values.rate * 100).toFixed(2)}%</p>
    </div>
    <div class="metric">
        <h3>Total Requests</h3>
        <p>Count: ${data.metrics.http_reqs.values.count}</p>
    </div>
</body>
</html>
  `;
  
  return html;
}