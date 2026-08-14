const http = require('http');
const https = require('https');
const fs = require('fs');
const path = require('path');

const PORT = process.env.PORT || 8080;
const PUBLIC_DIR = path.resolve(__dirname);
const API_INTERNAL_URL = process.env.API_INTERNAL_URL || 'http://sirc-api:3000';
const API_PROXY_PATHS = ['/api', '/api-docs', '/health'];

const MIME_TYPES = {
  '.html': 'text/html; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.json': 'application/json',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.gif': 'image/gif',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.apk': 'application/vnd.android.package-archive',
};

function shouldProxyToApi(pathname) {
  return API_PROXY_PATHS.some((prefix) => pathname === prefix || pathname.startsWith(`${prefix}/`));
}

function proxyToApi(req, res) {
  const target = new URL(req.url, API_INTERNAL_URL);
  const client = target.protocol === 'https:' ? https : http;
  const headers = {
    ...req.headers,
    host: target.host,
    'x-forwarded-host': req.headers.host || '',
    'x-forwarded-proto': req.headers['x-forwarded-proto'] || 'https',
  };

  const proxyReq = client.request(
    target,
    {
      method: req.method,
      headers,
    },
    (proxyRes) => {
      res.writeHead(proxyRes.statusCode || 502, proxyRes.headers);
      proxyRes.pipe(res);
    }
  );

  proxyReq.on('error', (error) => {
    res.writeHead(502, { 'Content-Type': 'application/json; charset=utf-8' });
    res.end(JSON.stringify({
      status: 'error',
      message: `No se pudo conectar con la API interna: ${error.message}`,
    }));
  });

  req.pipe(proxyReq);
}

const server = http.createServer((req, res) => {
  const requestUrl = new URL(req.url, `http://${req.headers.host || 'localhost'}`);
  const pathname = decodeURIComponent(requestUrl.pathname);

  if (shouldProxyToApi(pathname)) {
    proxyToApi(req, res);
    return;
  }

  const requestParts = pathname.split('/').filter((part) => part && part !== '..');
  let filePath = path.resolve(PUBLIC_DIR, requestParts.length === 0 ? 'index.html' : path.join(...requestParts));

  if (filePath !== PUBLIC_DIR && !filePath.startsWith(`${PUBLIC_DIR}${path.sep}`)) {
    res.writeHead(403, { 'Content-Type': 'text/plain; charset=utf-8' });
    res.end('403 Forbidden');
    return;
  }

  if (fs.existsSync(filePath) && fs.statSync(filePath).isDirectory()) {
    filePath = path.join(filePath, 'index.html');
  }

  const ext = path.extname(filePath).toLowerCase();
  const contentType = MIME_TYPES[ext] || 'application/octet-stream';
  const headers = { 'Content-Type': contentType };

  if (pathname.startsWith('/app/')) {
    headers['Cache-Control'] = 'no-store, no-cache, must-revalidate, proxy-revalidate';
    headers['Pragma'] = 'no-cache';
    headers['Expires'] = '0';
  }

  fs.readFile(filePath, (err, content) => {
    if (err) {
      if (err.code === 'ENOENT') {
        const appIndex = path.join(PUBLIC_DIR, 'app', 'index.html');
        if (pathname.startsWith('/app/') && fs.existsSync(appIndex)) {
          res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
          res.end(fs.readFileSync(appIndex), 'utf-8');
          return;
        }

        res.writeHead(404, { 'Content-Type': 'text/html; charset=utf-8' });
        res.end('<h1>404 Not Found</h1>');
      } else {
        res.writeHead(500);
        res.end(`Server Error: ${err.code}`);
      }
    } else {
      res.writeHead(200, headers);
      res.end(content, 'utf-8');
    }
  });
});

server.on('error', (error) => {
  if (error.code === 'EADDRINUSE') {
    console.error(`El puerto ${PORT} ya esta en uso. La landing probablemente ya esta corriendo en http://localhost:${PORT}`);
    process.exit(1);
  }

  throw error;
});

server.listen(PORT, () => {
  console.log(`Servidor SIRC corriendo en http://localhost:${PORT}`);
});
