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

export OPENROUTER_API_KEY="${OPENROUTER_API_KEY}"
export HERMES_HOME="/data/hermes"
export TELEGRAM_BOT_TOKEN="${TELEGRAM_BOT_TOKEN}"
export TELEGRAM_ALLOWED_USERS="${TELEGRAM_ALLOWED_USERS}"

mkdir -p "$HERMES_HOME"
mkdir -p /root/.hermes

# Write .env
printf 'OPENROUTER_API_KEY=%s\nTELEGRAM_BOT_TOKEN=%s\nTELEGRAM_ALLOWED_USERS=%s\n' \
    "${OPENROUTER_API_KEY}" "${TELEGRAM_BOT_TOKEN}" "${TELEGRAM_ALLOWED_USERS}" \
    > "$HERMES_HOME/.env"
cp "$HERMES_HOME/.env" /root/.hermes/.env

# Write config.yaml
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

# Register key via hermes config and show result
echo "DEBUG: Running hermes config set..."
hermes config set OPENROUTER_API_KEY "${OPENROUTER_API_KEY}" && echo "DEBUG: config set OK" || echo "DEBUG: config set FAILED"

# Show where hermes thinks its home is
echo "DEBUG: HERMES_HOME=${HERMES_HOME}"
echo "DEBUG: files in HERMES_HOME:"
ls -la "$HERMES_HOME/"
echo "DEBUG: files in /root/.hermes:"
ls -la /root/.hermes/ 2>/dev/null || echo "(empty)"

# Show what hermes config show says
echo "DEBUG: hermes config show:"
hermes config show 2>/dev/null | grep -i "openrouter\|auxiliary\|api_key" || echo "(nothing found)"

echo ""
echo "================================================"
echo "  Hermes Agent is running!"
echo "  Model: ${DEFAULT_MODEL}"
echo "  Auxiliary: ${AUXILIARY_MODEL}"
echo "  Telegram: enabled"
echo "================================================"
echo ""

exec hermes gateway