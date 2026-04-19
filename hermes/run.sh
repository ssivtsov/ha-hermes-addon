#!/usr/bin/env bash
set -e

CONFIG_PATH=/data/options.json

# Read config values
OPENROUTER_API_KEY=$(jq -r '.openrouter_api_key' $CONFIG_PATH)
TELEGRAM_BOT_TOKEN=$(jq -r '.telegram_bot_token' $CONFIG_PATH)
TELEGRAM_ALLOWED_USERS=$(jq -r '.telegram_allowed_users' $CONFIG_PATH)
DEFAULT_MODEL=$(jq -r '.default_model' $CONFIG_PATH)
HA_URL=$(jq -r '.ha_url' $CONFIG_PATH)
if [ -z "$HA_URL" ] || [ "$HA_URL" = "null" ] || [ "$HA_URL" = "" ]; then
    HA_URL="http://homeassistant:8123"
fi
HA_TOKEN=$(jq -r '.ha_token' $CONFIG_PATH)

# Create hermes data directory
mkdir -p /data/hermes

# Write hermes config.yaml
cat > /data/hermes/config.yaml << YAML
provider: openrouter
model: ${DEFAULT_MODEL}
openrouter_api_key: ${OPENROUTER_API_KEY}

home_assistant:
  url: ${HA_URL}
  token: ${HA_TOKEN}

data_dir: /data/hermes
YAML

# Write .env file for gateway (Hermes reads env vars from here)
cat > /data/hermes/.env << ENV
OPENROUTER_API_KEY=${OPENROUTER_API_KEY}
HERMES_DATA_DIR=/data/hermes
TELEGRAM_BOT_TOKEN=${TELEGRAM_BOT_TOKEN}
TELEGRAM_ALLOWED_USERS=${TELEGRAM_ALLOWED_USERS}
ENV

# Export all env vars
export OPENROUTER_API_KEY="${OPENROUTER_API_KEY}"
export HERMES_DATA_DIR="/data/hermes"
export HERMES_HOME="/data/hermes"

echo ""
echo "================================================"
echo "  Hermes Agent is running!"
echo "  Model: ${DEFAULT_MODEL}"

# Start Telegram gateway if token is set
if [ -n "$TELEGRAM_BOT_TOKEN" ] && [ "$TELEGRAM_BOT_TOKEN" != "null" ] && [ "$TELEGRAM_BOT_TOKEN" != "" ]; then
    export TELEGRAM_BOT_TOKEN="${TELEGRAM_BOT_TOKEN}"
    export TELEGRAM_ALLOWED_USERS="${TELEGRAM_ALLOWED_USERS}"
    echo "  Telegram: enabled"
    echo "================================================"
    echo ""
    echo "Starting Telegram gateway..."
    exec hermes gateway run
else
    echo "  Telegram: disabled (token not set)"
    echo "================================================"
    echo ""
    # Keep container alive
    tail -f /dev/null
fi