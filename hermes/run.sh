#!/usr/bin/env bash
set -e

CONFIG_PATH=/data/options.json

# Read config values
OPENROUTER_API_KEY=$(jq -r '.openrouter_api_key' $CONFIG_PATH)
TELEGRAM_BOT_TOKEN=$(jq -r '.telegram_bot_token' $CONFIG_PATH)
TELEGRAM_ALLOWED_USERS=$(jq -r '.telegram_allowed_users' $CONFIG_PATH)
DEFAULT_MODEL=$(jq -r '.default_model' $CONFIG_PATH)
AUXILIARY_MODEL=$(jq -r '.auxiliary_model' $CONFIG_PATH)
HA_URL=$(jq -r '.ha_url' $CONFIG_PATH)
if [ -z "$HA_URL" ] || [ "$HA_URL" = "null" ] || [ "$HA_URL" = "" ]; then
    HA_URL="http://homeassistant:8123"
fi
HA_TOKEN=$(jq -r '.ha_token' $CONFIG_PATH)

# Set HERMES_HOME
export HERMES_HOME="/data/hermes"
mkdir -p "$HERMES_HOME"

# Write hermes config.yaml
cat > "$HERMES_HOME/config.yaml" << YAML
provider: openrouter
model: ${DEFAULT_MODEL}
openrouter_api_key: ${OPENROUTER_API_KEY}

auxiliary:
  provider: openrouter
  model: ${AUXILIARY_MODEL}

home_assistant:
  url: ${HA_URL}
  token: ${HA_TOKEN}
YAML

# Write .env for gateway
cat > "$HERMES_HOME/.env" << ENV
OPENROUTER_API_KEY=${OPENROUTER_API_KEY}
TELEGRAM_BOT_TOKEN=${TELEGRAM_BOT_TOKEN}
TELEGRAM_ALLOWED_USERS=${TELEGRAM_ALLOWED_USERS}
ENV

echo ""
echo "================================================"
echo "  Hermes Agent is running!"
echo "  Model: ${DEFAULT_MODEL}"
echo "  Auxiliary: ${AUXILIARY_MODEL}"

if [ -n "$TELEGRAM_BOT_TOKEN" ] && [ "$TELEGRAM_BOT_TOKEN" != "null" ] && [ "$TELEGRAM_BOT_TOKEN" != "" ]; then
    echo "  Telegram: enabled"
    echo "================================================"
    echo ""
    exec hermes gateway
else
    echo "  Telegram: disabled"
    echo "================================================"
    echo ""
    tail -f /dev/null
fi