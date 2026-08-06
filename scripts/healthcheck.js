const http = require('http');

const port = Number(process.env.PORT || 3000);
const url = `http://127.0.0.1:${port}/health`;

http
  .get(url, (res) => {
    const chunks = [];
    res.on('data', (chunk) => chunks.push(chunk));
    res.on('end', () => {
      const body = Buffer.concat(chunks).toString('utf8').trim();
      if (res.statusCode !== 200 || !body.includes('"status":"ok"')) {
        console.error(`healthcheck failed: GET ${url} -> ${res.statusCode} ${body}`);
        process.exit(1);
      }
      console.log(`healthcheck ok: GET ${url} -> ${body}`);
    });
  })
  .on('error', (error) => {
    console.error(`healthcheck failed: GET ${url} -> ${error.message}`);
    process.exit(1);
  });
