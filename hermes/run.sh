#!/usr/bin/env bash
set -e

CONFIG_PATH=/data/options.json

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

# Use default ~/.hermes — no HERMES_HOME override
# Skills and data persist via /data/hermes symlink
mkdir -p /root/.hermes
mkdir -p /data/hermes

# Symlink sessions/skills/memories to persistent storage
for DIR in sessions skills memories cron logs; do
    mkdir -p "/data/hermes/$DIR"
    if [ ! -L "/root/.hermes/$DIR" ]; then
        rm -rf "/root/.hermes/$DIR"
        ln -s "/data/hermes/$DIR" "/root/.hermes/$DIR"
    fi
done

# Export env vars
export OPENROUTER_API_KEY="${OPENROUTER_API_KEY}"
export TELEGRAM_BOT_TOKEN="${TELEGRAM_BOT_TOKEN}"
export TELEGRAM_ALLOWED_USERS="${TELEGRAM_ALLOWED_USERS}"

# Write .env to default location
printf 'OPENROUTER_API_KEY=%s\nTELEGRAM_BOT_TOKEN=%s\nTELEGRAM_ALLOWED_USERS=%s\n' \
    "${OPENROUTER_API_KEY}" "${TELEGRAM_BOT_TOKEN}" "${TELEGRAM_ALLOWED_USERS}" \
    > /root/.hermes/.env

# Write config.yaml to default location
cat > /root/.hermes/config.yaml << YAML
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

echo ""
echo "================================================"
echo "  Hermes Agent is running!"
echo "  Model: ${DEFAULT_MODEL}"
echo "  Auxiliary: ${AUXILIARY_MODEL}"
echo "  Telegram: enabled"
echo "================================================"
echo ""

exec hermes gateway