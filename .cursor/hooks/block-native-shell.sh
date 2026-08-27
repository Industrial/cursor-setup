#!/usr/bin/env bash
# Blocks native Shell; agents must use lean-ctx ctx_shell (with devenv wrap).
# Evidence: .cursor/rules/lean-ctx.mdc, .cursor/rules/shell.mdc

set -euo pipefail
input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name // .toolName // empty')

case "$tool_name" in
    Shell|AwaitShell)
        cat <<'EOF'
{
  "permission": "deny",
  "user_message": "Native Shell is disabled. Use the lean-ctx MCP server (ctx_shell).",
  "agent_message": "STOP. Do not retry native Shell/AwaitShell. Use CallMcpTool with server project-0-solana-yield-optimizer-lean-ctx (or lean-ctx) and tool ctx_shell. Wrap commands with \"devenv shell --\" (see .cursor/rules/shell.mdc). Example: ctx_shell { command: \"devenv shell -- git status\" }. For verbatim output pass raw=true. GetMcpTools once for schema, then run. Never loop on native Shell."
}
EOF
        exit 0
        ;;
esac

echo '{"permission":"allow"}'
exit 0
