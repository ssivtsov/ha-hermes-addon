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

# Export env vars — must be before anything else
export OPENROUTER_API_KEY="${OPENROUTER_API_KEY}"
export HERMES_HOME="/data/hermes"

# Create both dirs — Hermes may look in ~/.hermes by default
mkdir -p "$HERMES_HOME"
mkdir -p /root/.hermes

# Write .env to BOTH locations
for DIR in "$HERMES_HOME" /root/.hermes; do
    cat > "$DIR/.env" << ENV
OPENROUTER_API_KEY=${OPENROUTER_API_KEY}
TELEGRAM_BOT_TOKEN=${TELEGRAM_BOT_TOKEN}
TELEGRAM_ALLOWED_USERS=${TELEGRAM_ALLOWED_USERS}
ENV
done

# Write config.yaml to BOTH locations
for DIR in "$HERMES_HOME" /root/.hermes; do
    cat > "$DIR/config.yaml" << YAML
provider: openrouter
model: ${DEFAULT_MODEL}

auxiliary:
  compression:
    provider: openrouter
    model: ${AUXILIARY_MODEL}
  vision:
    provider: openrouter
    model: ${AUXILIARY_MODEL}

tools:
  web_search:
    provider: duckduckgo

home_assistant:
  url: ${HA_URL}
  token: ${HA_TOKEN}
YAML
done

echo ""
echo "================================================"
echo "  Hermes Agent is running!"
echo "  Model: ${DEFAULT_MODEL}"
echo "  Auxiliary: ${AUXILIARY_MODEL}"
echo "  Web search: DuckDuckGo"

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