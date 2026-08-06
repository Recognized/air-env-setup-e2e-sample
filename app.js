const http = require('http');

const port = Number(process.env.PORT || 3000);
const service = 'air-env-setup-e2e-sample';

const server = http.createServer((req, res) => {
  if (req.url === '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ status: 'ok', service }) + '\n');
    return;
  }

  res.writeHead(200, { 'Content-Type': 'text/plain' });
  res.end(`${service} ok\n`);
});

server.listen(port, '0.0.0.0', () => console.log(`${service} listening on 0.0.0.0:${port}`));
