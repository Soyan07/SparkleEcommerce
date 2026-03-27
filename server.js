const http = require('http');
const https = require('https');
const { exec } = require('child_process');

// Configuration
const PORT = process.env.PORT || 3000;
const API_URL = process.env.API_URL || 'http://localhost:5000';
const HEALTH_CHECK_PATH = '/health';
const REQUEST_TIMEOUT = 5000;

// Simple in-memory cache
const cache = new Map();
const CACHE_TTL = 60000; // 1 minute

// Request counter
let requestCount = 0;
let startTime = Date.now();

// Logging utility
function log(level, message, meta = {}) {
  const timestamp = new Date().toISOString();
  console.log(JSON.stringify({ timestamp, level, message, ...meta }));
}

// Check if API is healthy
function checkApiHealth(callback) {
  const url = new URL(HEALTH_CHECK_PATH, API_URL);
  const protocol = url.protocol === 'https:' ? https : http;
  
  const req = protocol.get(url.href, { timeout: REQUEST_TIMEOUT }, (res) => {
    callback(null, res.statusCode >= 200 && res.statusCode < 300);
  });
  
  req.on('error', (err) => {
    log('error', 'Health check failed', { error: err.message });
    callback(err);
  });
  
  req.on('timeout', () => {
    req.destroy();
    callback(new Error('Health check timeout'));
  });
}

// Proxy request to API
function proxyRequest(req, res, path) {
  const url = new URL(path, API_URL);
  const protocol = url.protocol === 'https:' ? https : http;
  
  const options = {
    hostname: url.hostname,
    port: url.port || (url.protocol === 'https:' ? 443 : 80),
    path: url.pathname + url.search,
    method: req.method,
    headers: {
      ...req.headers,
      'X-Forwarded-Proto': 'https',
      'X-Forwarded-Host': req.headers.host,
      'X-Proxy-Time': Date.now().toString(),
    },
  };
  
  // Remove hop-by-hop headers
  delete options.headers['transfer-encoding'];
  delete options.headers['connection'];
  
  const proxyReq = protocol.request(options, (proxyRes) => {
    // Handle caching for GET requests
    if (req.method === 'GET' && proxyRes.statusCode === 200) {
      const cacheKey = path;
      const cached = cache.get(cacheKey);
      
      if (cached && Date.now() - cached.timestamp < CACHE_TTL) {
        res.setHeader('X-Cache', 'HIT');
        res.setHeader('X-Cache-Age', Math.floor((Date.now() - cached.timestamp) / 1000));
        res.end(cached.data);
        return;
      }
      
      // Buffer the response
      let data = '';
      proxyRes.on('data', chunk => data += chunk);
      proxyRes.on('end', () => {
        cache.set(cacheKey, { data, timestamp: Date.now() });
        res.setHeader('X-Cache', 'MISS');
        res.end(data);
      });
    } else {
      res.writeHead(proxyRes.statusCode, proxyRes.headers);
      proxyRes.pipe(res);
    }
  });
  
  proxyReq.on('error', (err) => {
    log('error', 'Proxy error', { error: err.message, path });
    res.statusCode = 502;
    res.end(JSON.stringify({ error: 'Bad Gateway', message: 'Failed to connect to API' }));
  });
  
  proxyReq.on('timeout', () => {
    proxyReq.destroy();
    res.statusCode = 504;
    res.end(JSON.stringify({ error: 'Gateway Timeout' }));
  });
  
  // Handle request body
  if (['POST', 'PUT', 'PATCH'].includes(req.method)) {
    req.pipe(proxyReq);
  } else {
    proxyReq.end();
  }
}

// Start server
const server = http.createServer((req, res) => {
  requestCount++;
  const start = Date.now();
  
  // CORS headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  
  // Handle preflight
  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    res.end();
    return;
  }
  
  const path = req.url.split('?')[0];
  
  // Health check endpoint
  if (path === '/health' || path === '/status') {
    checkApiHealth((err, isHealthy) => {
      if (err || !isHealthy) {
        res.writeHead(503, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ 
          status: 'unhealthy', 
          api: 'down',
          uptime: Math.floor((Date.now() - startTime) / 1000),
          requests: requestCount
        }));
      } else {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ 
          status: 'healthy', 
          api: 'up',
          uptime: Math.floor((Date.now() - startTime) / 1000),
          requests: requestCount
        }));
      }
    });
    return;
  }
  
  // Stats endpoint
  if (path === '/stats') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({
      uptime: Math.floor((Date.now() - startTime) / 1000),
      requests: requestCount,
      cacheSize: cache.size,
      memory: process.memoryUsage(),
      version: process.version
    }));
    return;
  }
  
  // Cache clear endpoint
  if (path === '/cache/clear' && req.method === 'POST') {
    cache.clear();
    log('info', 'Cache cleared');
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ status: 'cleared' }));
    return;
  }
  
  // Proxy all other requests to API
  proxyRequest(req, res, req.url);
  
  // Log request
  res.on('finish', () => {
    log('info', 'Request completed', {
      method: req.method,
      path,
      status: res.statusCode,
      duration: Date.now() - start
    });
  });
});

// Error handling
server.on('error', (err) => {
  log('error', 'Server error', { error: err.message });
  process.exit(1);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  log('info', 'SIGTERM received, shutting down gracefully');
  server.close(() => {
    log('info', 'Server closed');
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  log('info', 'SIGINT received, shutting down gracefully');
  server.close(() => {
    log('info', 'Server closed');
    process.exit(0);
  });
});

// Start
server.listen(PORT, () => {
  log('info', 'Server started', { 
    port: PORT, 
    apiUrl: API_URL,
    nodeVersion: process.version
  });
  console.log(`\n🚀 SparkleEcommerce Proxy Server`);
  console.log(`   Port: ${PORT}`);
  console.log(`   API:  ${API_URL}`);
  console.log(`   Health: http://localhost:${PORT}/health\n`);
});
