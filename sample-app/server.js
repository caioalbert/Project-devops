const apm = require('@elastic/apm-node').start({
  serviceName: 'sample-node-app',
  serverUrl: process.env.ELASTIC_APM_SERVER_URL || 'http://elasticsearch-es-http:9200',
  secretToken: process.env.ELASTIC_APM_SECRET_TOKEN,
  environment: process.env.NODE_ENV || 'production'
});

const express = require('express');
const client = require('prom-client');

const app = express();
const port = process.env.PORT || 3000;

// Prometheus metrics
const register = new client.Registry();
client.collectDefaultMetrics({ register });

const httpRequestDuration = new client.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.1, 0.3, 0.5, 0.7, 1, 3, 5, 7, 10]
});

register.registerMetric(httpRequestDuration);

// Middleware para métricas
app.use((req, res, next) => {
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    httpRequestDuration
      .labels(req.method, req.route?.path || req.path, res.statusCode)
      .observe(duration);
  });
  
  next();
});

app.get('/', (req, res) => {
  console.log('Request received at /');
  res.json({ message: 'Hello from Sample Node App!', timestamp: new Date().toISOString() });
});

app.get('/health', (req, res) => {
  res.json({ status: 'healthy', uptime: process.uptime() });
});

app.get('/metrics', (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(register.metrics());
});

app.get('/error', (req, res) => {
  // Simular erro para APM
  const error = new Error('Simulated error for APM testing');
  apm.captureError(error);
  res.status(500).json({ error: 'Simulated error' });
});

app.listen(port, () => {
  console.log(`Sample app listening on port ${port}`);
});
