#!/usr/bin/env bash
set -e

CONFIG_PATH=/data/options.json

# Read config values
OPENROUTER_API_KEY=$(jq -r '.openrouter_api_key' $CONFIG_PATH)
TELEGRAM_BOT_TOKEN=$(jq -r '.telegram_bot_token' $CONFIG_PATH)
TELEGRAM_ALLOWED_USERS=$(jq -r '.telegram_allowed_users' $CONFIG_PATH)
DEFAULT_MODEL=$(jq -r '.default_model' $CONFIG_PATH)
HA_URL=$(jq -r '.ha_url' $CONFIG_PATH)
if [ -z "$HA_URL" ] || [ "$HA_URL" = "null" ]; then
    HA_URL="http://homeassistant:8123"
fi
HA_TOKEN=$(jq -r '.ha_token' $CONFIG_PATH)

# Create hermes config directory
mkdir -p /data/hermes

# Write hermes config file
cat > /data/hermes/config.yaml << EOF
provider: openrouter
model: ${DEFAULT_MODEL}
openrouter_api_key: ${OPENROUTER_API_KEY}

home_assistant:
  url: ${HA_URL}
  token: ${HA_TOKEN}

data_dir: /data/hermes
EOF

# Write gateway config if telegram token is set
if [ -n "$TELEGRAM_BOT_TOKEN" ] && [ "$TELEGRAM_BOT_TOKEN" != "null" ] && [ "$TELEGRAM_BOT_TOKEN" != "" ]; then
    cat > /data/hermes/gateway.yaml << EOF
telegram:
  token: ${TELEGRAM_BOT_TOKEN}
  allowed_users: [${TELEGRAM_ALLOWED_USERS}]
EOF

    echo "Starting Hermes Agent with Telegram gateway..."
    export OPENROUTER_API_KEY="${OPENROUTER_API_KEY}"
    export HERMES_DATA_DIR="/data/hermes"

    # Start telegram gateway in background
    hermes gateway start --config /data/hermes/gateway.yaml &
    GATEWAY_PID=$!
    echo "Telegram gateway started (PID: $GATEWAY_PID)"
else
    echo "Telegram token not set, skipping gateway"
fi

echo ""
echo "================================================"
echo "  Hermes Agent is running!"
echo "  Model: ${DEFAULT_MODEL}"
if [ -n "$TELEGRAM_BOT_TOKEN" ] && [ "$TELEGRAM_BOT_TOKEN" != "null" ]; then
echo "  Telegram: enabled"
fi
echo ""
echo "  To use CLI: open Terminal addon and run:"
echo "  docker exec -it addon_hermes hermes"
echo "================================================"
echo ""

# Keep container alive
tail -f /dev/null
