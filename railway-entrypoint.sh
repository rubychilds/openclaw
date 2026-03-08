#!/bin/sh
set -e

# Create config directory
mkdir -p ~/.openclaw

# Write gateway config
cat > ~/.openclaw/openclaw.json <<'CONF'
{
  "gateway": {
    "controlUi": {
      "dangerouslyAllowHostHeaderOriginFallback": true
    },
    "http": {
      "endpoints": {
        "responses": {
          "enabled": true
        }
      }
    }
  }
}
CONF

# Write auth-profiles.json if ANTHROPIC_API_KEY is set
if [ -n "$ANTHROPIC_API_KEY" ]; then
  AGENT_DIR="$HOME/.openclaw/agents/main/agent"
  mkdir -p "$AGENT_DIR"
  cat > "$AGENT_DIR/auth-profiles.json" <<EOF
{
  "version": 1,
  "profiles": {
    "anthropic-env": {
      "type": "token",
      "provider": "anthropic",
      "token": "$ANTHROPIC_API_KEY"
    }
  }
}
EOF
  echo "[railway-entrypoint] Wrote auth-profiles.json for anthropic provider"
fi

exec node openclaw.mjs gateway --allow-unconfigured --bind lan --port "${PORT:-18789}"
