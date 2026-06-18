const express = require('express');
const cors = require('cors');
const { getPool } = require('./db');
const app = express();
app.use(cors());
app.use(express.json());
const PORT = process.env.PORT || 8080;

app.get('/api/metrics/health', (req, res) => res.json({ status: 'ok', service: 'metrics-api' }));

// Dashboard: indicadores agregados
app.get('/api/metrics', async (req, res) => {
  try {
    const pool = await getPool();
    const q = await pool.request().query(`
      USE SupportDB;
      SELECT
        (SELECT COUNT(*) FROM Tickets) AS total,
        (SELECT COUNT(*) FROM Tickets WHERE estado='Abierto') AS abiertos,
        (SELECT COUNT(*) FROM Tickets WHERE estado='Cerrado') AS cerrados,
        (SELECT COUNT(*) FROM Tickets WHERE prioridad='Alta') AS alta,
        (SELECT COUNT(*) FROM Tickets WHERE prioridad='Media') AS media,
        (SELECT COUNT(*) FROM Tickets WHERE prioridad='Baja') AS baja;
    `);
    res.json(q.recordset[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

app.listen(PORT, () => console.log(`metrics-api en puerto ${PORT}`));
