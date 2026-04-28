const http = require('http');
const fs = require('fs');
const path = require('path');
const root = path.dirname(__filename);
const mime = {'.html':'text/html;charset=utf-8','.css':'text/css','.js':'application/javascript','.png':'image/png','.jpg':'image/jpeg','.svg':'image/svg+xml','.ico':'image/x-icon','.mp4':'video/mp4','.mov':'video/mp4','.webm':'video/webm'};
http.createServer((req, res) => {
  let p = req.url === '/' ? '/index.html' : req.url;
  const file = path.join(root, p.split('?')[0]);
  fs.readFile(file, (err, data) => {
    if (err) { res.writeHead(404); res.end('Not found'); return; }
    res.writeHead(200, {'Content-Type': mime[path.extname(file)] || 'application/octet-stream'});
    res.end(data);
  });
}).listen(8080, () => console.log('Server running at http://localhost:8080'));
