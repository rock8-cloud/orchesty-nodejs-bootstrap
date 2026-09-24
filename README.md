# Orchesty Node.js Bootstrap

A ready-to-fork starter template for building [Orchesty](https://orchesty.io) integration workers in Node.js + TypeScript. It ships with the [`@orchesty/nodejs-sdk`](https://www.npmjs.com/package/@orchesty/nodejs-sdk), a Make-driven dev workflow, a multi-stage production `Dockerfile`, and the [`@orchesty/nodejs-ai`](https://github.com/Orchesty/orchesty-nodejs-ai) rules package so AI coding assistants (Cursor, Claude Code, Windsurf, GitHub Copilot, Cline, Aider, ...) generate code that matches Orchesty conventions out of the box. The worker deploys to [Rock8Cloud](https://rock8.cloud) in one click.

[![Deploy on Rock8Cloud](https://img.shields.io/badge/Deploy%20on-Rock8Cloud-06b6d4?style=for-the-badge)](https://app.rock8.cloud/login?redirect=%2Fnew-deployment%3Fblueprint%3Dorchesty-nodejs-bootstrap%26utm_source%3Dgithub%26utm_medium%3Dreadme%26utm_campaign%3Dblueprint)

## Quickstart with AI tools (Cursor, Claude Code, ...)

This is the recommended path. Open your AI coding tool inside an empty folder and paste the prompt below. The agent does the rest: clones the repo, installs dependencies, materializes the AI rules into its own rule directory, and starts building the integration you describe.

```
Bootstrap an Orchesty integration worker in the current directory.

1. Clone https://github.com/rock8-cloud/orchesty-nodejs-bootstrap.git into the current directory (no `my-worker` subfolder), then `rm -rf .git && git init`.
2. Open AGENTS.md and follow its "Setup workflow" section in order. It picks between local Node.js and Docker based on what's available on the host (and asks me if both work), brings up the project, materializes the AI rules into your tool's native rule directory, and verifies the build.

Then build the integration described below.
```

Append your integration brief at the bottom of the prompt before sending it. Per-tool rule paths and update flow are documented in [`node_modules/@orchesty/nodejs-ai/AI-INSTRUCTIONS.md`](https://github.com/Orchesty/orchesty-nodejs-ai/blob/master/AI-INSTRUCTIONS.md) once the package is installed.

## Manual quickstart (without AI)

Click **Use this template** on GitHub, or clone it directly:

```bash
git clone https://github.com/rock8-cloud/orchesty-nodejs-bootstrap.git my-worker
cd my-worker
rm -rf .git && git init
make init-dev          # installs deps, generates .env, starts the dev server
```

Docker variant (no local Node.js required):

```bash
make init-dev-docker
```

That's the entire setup. The AI rule files in `node_modules/@orchesty/nodejs-ai/rules/` only matter when you drive the codebase with an AI coding assistant. For plain manual development you can ignore them.

## Project structure

```
.
├── src/
│   └── index.ts            # Worker entry point: register Applications and Nodes here
├── .jest/                  # Jest setup helpers
├── docker/                 # Dev container support files
├── docker-compose.yaml     # Dev container definition (used by `make init-dev-docker`)
├── Dockerfile              # Multi-stage production image (used by Rock8Cloud and `make build`)
├── Makefile                # Canonical entry point. See "Make targets" below
├── AGENTS.md               # Setup workflow for AI agents (Cursor, Claude Code, ...)
├── .mcp.json               # Rock8Cloud MCP endpoint, for agent-driven deploys
├── .env.dist               # Template; `make` auto-generates `.env` from this on first run
├── package.json
└── tsconfig*.json
```

## Make targets


| Target                               | What it does                                                        |
| ------------------------------------ | ------------------------------------------------------------------- |
| `make install`                       | Installs dependencies (auto-detects `pnpm`/`npm`).                  |
| `make start`                         | Runs the dev server (`nodemon src/index.ts`). Blocking.             |
| `make init-dev`                      | `install` + `start` in one shot. Auto-generates `.env`.             |
| `make test`                          | Lint + unit tests.                                                  |
| `make lint`                          | ESLint with `--fix`.                                                |
| `make build IMAGE=registry/name:tag` | Builds and pushes the multi-stage production image (`linux/amd64`). |


Docker variants run the same operations inside the dev container defined in `docker-compose.yaml`:


| Target                   | What it does                                                                                 |
| ------------------------ | -------------------------------------------------------------------------------------------- |
| `make init-dev-docker`   | `docker compose up` + install + start, all inside the container.                             |
| `make install-docker`    | `pnpm install` inside the worker container.                                                  |
| `make start-docker`      | Runs the dev server inside the container.                                                    |
| `make test-docker`       | Brings up containers, runs lint + tests, then tears them down with `docker compose down -v`. |
| `make docker-down-clean` | Stops the dev container and deletes its volumes.                                             |


## Docker workflow

`make init-dev-docker` is the one-liner for the volume-mounted dev container. Code changes on the host trigger nodemon inside the container. The root `Dockerfile` is the multi-stage production build; build and push it with `make build IMAGE=registry/name:tag`.

## Environment variables

The worker needs `CRYPT_SECRET` plus a way to reach your Orchesty instance. Choose **one** way:

- **Orchesty Cloud:** set `TENANT_ID` (and `CLOUD_REGION` if it isn't `eu2`). The SDK derives every backend URL from them.
- **Self-hosted Orchesty:** leave `TENANT_ID` empty and set `BACKEND_URL`, `STARTING_POINT_URL` and `WORKER_API_HOST` explicitly.

Without either, the worker exits on boot with `Env [BACKEND_URL] is missing.`

| Variable             | Required                   | Description                                                                                          |
| -------------------- | -------------------------- | ---------------------------------------------------------------------------------------------------- |
| `CRYPT_SECRET`       | **yes**                    | Key used to encrypt stored application credentials. Generate with `openssl rand -base64 32`.         |
| `ORCHESTY_API_KEY`   | yes, in deployment         | API key the worker uses to talk to Orchesty.                                                        |
| `TENANT_ID`          | Orchesty Cloud             | Your Orchesty Cloud tenant. `local` and `docker` are reserved for development (see `.env.dist`).     |
| `CLOUD_REGION`       | no                         | Orchesty Cloud region, default `eu2`.                                                               |
| `BACKEND_URL`        | self-hosted                | Orchesty backend URL.                                                                                |
| `STARTING_POINT_URL` | self-hosted                | Orchesty starting-point URL.                                                                         |
| `WORKER_API_HOST`    | self-hosted                | Orchesty worker-api URL.                                                                             |
| `TUNNEL_ENABLED`     | no                         | `true` to connect through the Orchesty tunnel instead of a public URL. Mainly for local development. |
| `TUNNEL_WORKER_ID`   | with `TUNNEL_ENABLED=true` | Worker ID registered in Orchesty for the tunnel.                                                    |
| `APP_PORT`           | no                         | Port the worker listens on, default `8080`. In the Docker image, `PORT` takes precedence.           |
| `LOGGER_TYPE`        | no                         | Logger output format.                                                                                |

`DEV_UID`, `DEV_GID` and `DEV_IP` in `.env.dist` are only used by the local dev setup.

## Deploy on [Rock8Cloud](https://rock8.cloud)

[![Deploy on Rock8Cloud](https://img.shields.io/badge/Deploy%20on-Rock8Cloud-06b6d4?style=for-the-badge)](https://app.rock8.cloud/login?redirect=%2Fnew-deployment%3Fblueprint%3Dorchesty-nodejs-bootstrap%26utm_source%3Dgithub%26utm_medium%3Dreadme%26utm_campaign%3Dblueprint)

Click the button to sign in, clone this blueprint to your GitHub account, and deploy the worker through the Rock8Cloud UI.

### Deploy your own repository

You can also create your own repository from this blueprint and deploy it with an MCP-capable coding agent. This repository includes [`.mcp.json`](.mcp.json) with the Rock8Cloud MCP endpoint already configured. Open the repository in your agent (Claude Code, for example), complete the OAuth login when prompted, and ask:

```text
Deploy this project to Rock8Cloud.
```

You don't need an API key, a deployment CLI or a GitHub Actions workflow. The agent follows these steps. You can also do them by hand in the Rock8Cloud UI:

1. **Push this repository to GitHub** and make sure Rock8Cloud can see it (`check_github_connection`).
2. **Create a project** (`create_project`).
3. **Create the worker service** from the repo (`create_repo_service`): Dockerfile `Dockerfile` at the repository root, container port **8080**.
4. **Set the environment** (`write_manual_env_vars`): `CRYPT_SECRET`, `ORCHESTY_API_KEY`, and either `TENANT_ID` or the three self-hosted URLs (see [Environment variables](#environment-variables)).
5. **Deploy** (`deploy_service`) and check `get_deployment_status` / `get_runtime_logs`.
6. **Register the worker in Orchesty** using the service's public URL.

Every push to `main` redeploys automatically.

Verify the image locally before deploying:

```bash
docker build -t orchesty-worker .
docker run --rm -p 8080:8080 -e CRYPT_SECRET=dev -e TENANT_ID=my-tenant orchesty-worker
curl localhost:8080/applications   # {"items":[]}
```

> `PORT` is injected by the platform and maps onto the SDK's `APP_PORT` in the image's `CMD`. Don't set it manually. The `EXPOSE`d port (8080) must match the port configured on the Rock8Cloud service, or health checks will fail.

## How AI rules work

Rules ship as the npm package [`@orchesty/nodejs-ai`](https://github.com/Orchesty/orchesty-nodejs-ai), pinned in `package.json` as a dev dependency. When you use this template with an AI coding assistant, [AGENTS.md](AGENTS.md) tells the agent to materialize the `.mdc` rule files from `node_modules/@orchesty/nodejs-ai/rules/` into the tool's native rule directory; per-tool snippets (Cursor's `.cursor/rules/`, Claude Code's `CLAUDE.md`, Windsurf's `.windsurfrules`, etc.) live in [`node_modules/@orchesty/nodejs-ai/AI-INSTRUCTIONS.md`](https://github.com/Orchesty/orchesty-nodejs-ai/blob/master/AI-INSTRUCTIONS.md). You don't have to do this by hand.

To pull rule updates: `pnpm update @orchesty/nodejs-ai`, then ask your AI tool to re-run the AGENTS.md setup workflow (or copy the refreshed `.mdc` files yourself if you prefer).

## Documentation

- [Orchesty platform docs](https://docs.orchesty.io/)
- [`@orchesty/nodejs-sdk` on npm](https://www.npmjs.com/package/@orchesty/nodejs-sdk)
- [Pre-built `@orchesty/connector-*` packages](https://www.npmjs.com/search?q=%40orchesty%2Fconnector)
- [Connector source examples](https://github.com/Orchesty/orchesty-nodejs-connectors/tree/master/lib)
- [Rock8Cloud](https://rock8.cloud)

## Community

- [Discord](https://discord.gg/orchesty)
- [Issues](https://github.com/rock8-cloud/orchesty-nodejs-bootstrap/issues). Pull requests are welcome. Please run `make test` before opening a PR.

## License

Apache-2.0. See [LICENSE](LICENSE).
