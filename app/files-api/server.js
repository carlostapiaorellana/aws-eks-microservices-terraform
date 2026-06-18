const express = require('express');
const cors = require('cors');
const { S3Client, PutObjectCommand, GetObjectCommand, ListObjectsV2Command } = require('@aws-sdk/client-s3');
const { getSignedUrl } = require('@aws-sdk/s3-request-presigner');

const app = express();
app.use(cors());
app.use(express.json());
const PORT = process.env.PORT || 8080;
const BUCKET = process.env.ATTACHMENTS_BUCKET;
const s3 = new S3Client({ region: process.env.AWS_REGION || 'us-east-1' });

app.get('/api/files/health', (req, res) => res.json({ status: 'ok', service: 'files-api' }));

// Generar URL prefirmada para subir
app.post('/api/files/upload-url', async (req, res) => {
  try {
    const { filename, ticketId } = req.body;
    const key = `tickets/${ticketId || 'general'}/${Date.now()}-${filename}`;
    const url = await getSignedUrl(s3, new PutObjectCommand({ Bucket: BUCKET, Key: key }), { expiresIn: 300 });
    res.json({ uploadUrl: url, key });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

// Listar archivos de un ticket
app.get('/api/files/:ticketId', async (req, res) => {
  try {
    const r = await s3.send(new ListObjectsV2Command({ Bucket: BUCKET, Prefix: `tickets/${req.params.ticketId}/` }));
    const files = (r.Contents || []).map(o => ({ key: o.Key, size: o.Size, lastModified: o.LastModified }));
    res.json(files);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.listen(PORT, () => console.log(`files-api en puerto ${PORT}`));
