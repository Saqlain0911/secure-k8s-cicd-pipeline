const express = require('express');
const { Pool } = require('pg');

const app = express();
const port = process.env.PORT || 3000;

// Database connection setup
// In Phase 3, process.env.DATABASE_URL will be injected securely via K8s Secrets!
const pool = new Pool({
  connectionString: process.env.DATABASE_URL || 'postgresql://dummy_user:dummy_pass@localhost:5432/dummy_db'
});

// Root route
app.get('/', (req, res) => {
  res.send('Hello from the Secure K8s CI/CD Pipeline App!');
});

// HEALTH PROBE: Required for K8s Liveness and Readiness probes (Phase 3)
app.get('/health', (req, res) => {
  res.status(200).json({ 
    status: 'healthy', 
    timestamp: new Date().toISOString() 
  });
});

// DATABASE STATUS ROUTE: To test our StatefulSet later
app.get('/db-status', async (req, res) => {
  try {
    const client = await pool.connect();
    client.release();
    res.status(200).json({ status: 'Database connected successfully!' });
  } catch (err) {
    // Note: This will fail right now because we haven't built the DB yet. That's expected!
    res.status(500).json({ 
      status: 'Database connection failed (Expected in Phase 0)', 
      error: err.message 
    });
  }
});

app.listen(port, () => {
  console.log(`App listening at http://localhost:${port}`);
  console.log(`Running as user UID: ${process.getuid ? process.getuid() : 'Unknown'}`);
});