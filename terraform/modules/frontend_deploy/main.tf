resource "aws_s3_object" "index" {
  bucket        = var.bucket_id
  key           = "index.html"
  content_type  = "text/html"
  cache_control = "max-age=60"
  etag          = md5("placeholder-v1")
  content       = <<-HTML
    <!DOCTYPE html>
    <html lang="es"><head><meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>IT Support System - Lab</title>
    <style>
      body{font-family:-apple-system,sans-serif;background:linear-gradient(135deg,#0f1e3a,#1a2f5c);color:#fff;margin:0;min-height:100vh;display:flex;align-items:center;justify-content:center}
      .c{text-align:center;padding:2rem}h1{font-size:3rem;margin-bottom:.5rem}
      .tag{display:inline-block;background:#1f4480;padding:.3rem .8rem;border-radius:.5rem;font-size:1rem;margin-left:.5rem}
      .s{margin-top:2rem;padding:1rem;background:rgba(0,200,100,.2);border:1px solid rgba(0,200,100,.5);border-radius:.5rem}
    </style></head><body><div class="c">
    <h1>IT Support System <span class="tag">Lab 5 - AWS</span></h1>
    <p>Frontend placeholder - CloudFront + S3</p>
    <div class="s">Infraestructura desplegada. Frontend real en Fase 6.</div>
    </div></body></html>
  HTML
}
