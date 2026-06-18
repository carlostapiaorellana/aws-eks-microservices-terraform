const sql = require('mssql');
const { SecretsManagerClient, GetSecretValueCommand } = require('@aws-sdk/client-secrets-manager');

let pool = null;

async function getDbConfig() {
  const secretArn = process.env.DB_SECRET_ARN;
  const region = process.env.AWS_REGION || 'us-east-1';
  const client = new SecretsManagerClient({ region });
  const resp = await client.send(new GetSecretValueCommand({ SecretId: secretArn }));
  const s = JSON.parse(resp.SecretString);
  return {
    user: s.username,
    password: s.password,
    server: s.host,
    port: parseInt(s.port, 10),
    database: 'master',
    options: { encrypt: true, trustServerCertificate: true },
    pool: { max: 5, min: 0, idleTimeoutMillis: 30000 }
  };
}

async function getPool() {
  if (pool) return pool;
  const config = await getDbConfig();
  pool = await sql.connect(config);
  await initSchema();
  return pool;
}

async function initSchema() {
  // Crea la DB SupportDB y la tabla Tickets si no existen
  await pool.request().query(`
    IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'SupportDB')
      CREATE DATABASE SupportDB;
  `);
  await pool.request().query(`
    USE SupportDB;
    IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Tickets' AND xtype='U')
      CREATE TABLE Tickets (
        id INT IDENTITY(1,1) PRIMARY KEY,
        usuario NVARCHAR(100) NOT NULL,
        asunto NVARCHAR(255) NOT NULL,
        prioridad NVARCHAR(20) DEFAULT 'Media',
        estado NVARCHAR(20) DEFAULT 'Abierto',
        creado_en DATETIME DEFAULT GETDATE()
      );
  `);
}

module.exports = { getPool, sql };
