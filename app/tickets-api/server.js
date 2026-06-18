const express = require('express');
const cors = require('cors');
const { getPool, sql } = require('./db');

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 8080;

// Health check (sin DB, para que K8s no reinicie el pod si la DB tarda)
app.get('/api/tickets/health', (req, res) => res.json({ status: 'ok', service: 'tickets-api' }));

// Listar tickets
app.get('/api/tickets', async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().query('USE SupportDB; SELECT * FROM Tickets ORDER BY creado_en DESC');
    res.json(result.recordset);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

// Crear ticket
app.post('/api/tickets', async (req, res) => {
  try {
    const { usuario, asunto, prioridad } = req.body;
    if (!usuario || !asunto) return res.status(400).json({ error: 'usuario y asunto son requeridos' });
    const pool = await getPool();
    await pool.request()
      .input('usuario', sql.NVarChar, usuario)
      .input('asunto', sql.NVarChar, asunto)
      .input('prioridad', sql.NVarChar, prioridad || 'Media')
      .query('USE SupportDB; INSERT INTO Tickets (usuario, asunto, prioridad) VALUES (@usuario, @asunto, @prioridad)');
    res.status(201).json({ message: 'Ticket creado' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

// Actualizar estado
app.put('/api/tickets/:id', async (req, res) => {
  try {
    const { estado } = req.body;
    const pool = await getPool();
    await pool.request()
      .input('id', sql.Int, parseInt(req.params.id, 10))
      .input('estado', sql.NVarChar, estado)
      .query('USE SupportDB; UPDATE Tickets SET estado=@estado WHERE id=@id');
    res.json({ message: 'Ticket actualizado' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.listen(PORT, () => console.log(`tickets-api en puerto ${PORT}`));
