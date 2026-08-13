const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = process.env.PORT || 8080;
const PUBLIC_DIR = path.resolve(__dirname);

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

const server = http.createServer((req, res) => {
  const requestUrl = new URL(req.url, `http://${req.headers.host || 'localhost'}`);
  const pathname = decodeURIComponent(requestUrl.pathname);
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
