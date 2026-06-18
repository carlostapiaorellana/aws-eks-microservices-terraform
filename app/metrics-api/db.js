const sql = require('mssql');
const { SecretsManagerClient, GetSecretValueCommand } = require('@aws-sdk/client-secrets-manager');
let pool = null;
async function getDbConfig() {
  const client = new SecretsManagerClient({ region: process.env.AWS_REGION || 'us-east-1' });
  const resp = await client.send(new GetSecretValueCommand({ SecretId: process.env.DB_SECRET_ARN }));
  const s = JSON.parse(resp.SecretString);
  return {
    user: s.username, password: s.password, server: s.host, port: parseInt(s.port, 10),
    database: 'master', options: { encrypt: true, trustServerCertificate: true },
    pool: { max: 5, min: 0, idleTimeoutMillis: 30000 }
  };
}
async function getPool() {
  if (pool) return pool;
  pool = await sql.connect(await getDbConfig());
  return pool;
}
module.exports = { getPool, sql };
