# air-env-setup-e2e-sample

Fixture repository for the **Air environment setup** end-to-end release gate. It is deliberately
minimal and **requires no secrets**, so an automated test can run the whole setup journey
unattended.

Do not use this repository for manual experiments: the gate creates and deletes
`air/env-setup/<runId>` branches here, and it expects the default branch to stay unchanged.

## The app

A zero-dependency Node HTTP server. There is nothing to install.

| | |
|---|---|
| Start command | `npm start` |
| Port | `PORT`, default `3000`, bound to `0.0.0.0` |
| Health endpoint | `GET /health` → `200` with `{"status":"ok","service":"air-env-setup-e2e-sample"}` |
| Any other path | `200` with `air-env-setup-e2e-sample ok` |
| Health check command | `npm run healthcheck` (exits non-zero until `/health` answers) |

```bash
npm start           # in one shell
npm run healthcheck # in another; prints "healthcheck ok: ..."
```

## What the setup agent is expected to produce

There is intentionally **no** `.air/cloud/startup.sh` in this repository. Automatic environment
setup generates it, commits it to the run's setup branch, and pushes it. That script is expected
to start the server in the background, define a `healthcheck` function that waits for
`GET /health` to answer (`npm run healthcheck` is enough), and call that function during warmup.

No environment variables or secrets are needed beyond the optional `PORT`.
