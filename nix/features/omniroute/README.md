# OmniRoute

Local AI gateway with free-tier routing and an OpenAI-compatible API.

- API: `http://127.0.0.1:20128/v1`
- Dashboard: `http://127.0.0.1:20128`

## First-time setup

1. Rebuild NixOS on a host with the AI profile (`mimir`, `drakkar`).
2. Enable and start the user service (defined in `features/ai/omniroute/default.nix`):

   ```bash
   systemctl --user enable --now omniroute.service
   ```

3. Open the dashboard, set an admin password, and connect free providers.
4. Create an endpoint API key for Hermes.
5. Copy `features/ai/hermes-agent/.hermes/.env.example` to `~/.hermes/.env` and set `OMNIROUTE_API_KEY`.
6. Merge `auth.json.example` into `~/.hermes/auth.json` (or add the `openrouter` credential pool entry).

## Hermes

Hermes defaults to **CheapestInference** (`model.provider: cheapestinference`). OmniRoute remains a custom provider you can switch to:

- `model.provider`: `omniroute`
- `model.base_url`: `http://127.0.0.1:20128/v1`
- `custom_providers[].key_env`: `OMNIROUTE_API_KEY`
- `model.default`: `auto/coding:free`

Set `OMNIROUTE_API_KEY` in `$PWD/.hermes/.env` (this repo sets `HERMES_HOME` to the project `.hermes/`). Suppress `env:OPENROUTER_API_KEY` in `auth.json` if you also have `OPENROUTER_API_KEY` in `.env`, or Hermes will re-seed a direct OpenRouter credential and bypass OmniRoute.
