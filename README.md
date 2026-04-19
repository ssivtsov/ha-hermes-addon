# Hermes Agent — HAOS Addon

Self-improving AI agent by Nous Research, packaged as a Home Assistant addon.

## Установка

1. Зайди в HA → Настройки → Аддоны → Магазин аддонов
2. Нажми три точки (⋮) → **Добавить репозиторий**
3. Вставь URL твоего GitHub репозитория
4. Найди "Hermes Agent" и установи

## Настройка

В конфигурации аддона заполни:

| Параметр | Описание |
|---|---|
| `openrouter_api_key` | API ключ с [openrouter.ai](https://openrouter.ai) |
| `telegram_bot_token` | Токен бота от [@BotFather](https://t.me/BotFather) (опционально) |
| `telegram_allowed_users` | Твой Telegram user_id через запятую (узнать: [@userinfobot](https://t.me/userinfobot)) |
| `default_model` | Модель OpenRouter, например `anthropic/claude-3.5-sonnet` |
| `ha_url` | URL Home Assistant, обычно `http://homeassistant:8123` |
| `ha_token` | Long-lived access token из профиля HA |

## Использование

### Telegram
Просто напиши своему боту — Hermes ответит и выполнит задачи.

### CLI
Открой Terminal аддон в HA и выполни:
```bash
docker exec -it addon_hermes hermes
```

## Получить HA токен

HA → Профиль (внизу слева) → Долгосрочные токены доступа → Создать токен
