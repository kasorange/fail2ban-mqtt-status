#!/bin/bash
set -euo pipefail

MQTT_USER=""
MQTT_PASS=""
MQTT_HOST=""
MQTT_PORT="1883"
MQTT_PREFIX="fail2ban/traefik-login"

JAIL="traefik-login"

# Préfixes MQTT
BASE_PREFIX="fail2ban/${JAIL}"
DISCOVERY_PREFIX="homeassistant"

MOSQUITTO_PUB="$(command -v mosquitto_pub || echo /usr/bin/mosquitto_pub)"

# ===============================
#  Récupération du status fail2ban
# ===============================
OUTPUT="$(fail2ban-client status "$JAIL" 2>/dev/null || true)"

get_value() {
  local label="$1"; local default="${2:-0}"
  local val
  val="$(printf '%s\n' "$OUTPUT" | grep -i -m1 -E "$label" | sed -E 's/[^0-9]*([0-9]+).*/\1/')" || true
  if [ -z "$val" ]; then printf '%s' "$default"; else printf '%s' "$val"; fi
}

CURRENTLY_FAILED="$(get_value 'Currently failed' 0)"
TOTAL_FAILED="$(get_value 'Total failed' 0)"
CURRENTLY_BANNED="$(get_value 'Currently banned' 0)"
TOTAL_BANNED="$(get_value 'Total banned' 0)"

# ===============================
# Publication des métriques
# ===============================
publish_value() {
  local topic="$1"
  local value="$2"
  "$MOSQUITTO_PUB" -h "$MQTT_HOST" -p "$MQTT_PORT" \
    -u "$MQTT_USER" -P "$MQTT_PASS" \
    -t "${BASE_PREFIX}/${topic}" -m "$value" -r
}

publish_value "currently_failed" "$CURRENTLY_FAILED"
publish_value "total_failed" "$TOTAL_FAILED"
publish_value "currently_banned" "$CURRENTLY_BANNED"
publish_value "total_banned" "$TOTAL_BANNED"

# ===============================
#     AUTO-DISCOVERY HA
# ===============================
publish_discovery() {
  local sensor="$1"
  local friendly="$2"
  local icon="$3"

  "$MOSQUITTO_PUB" -h "$MQTT_HOST" -p "$MQTT_PORT" \
    -u "$MQTT_USER" -P "$MQTT_PASS" \
    -t "${DISCOVERY_PREFIX}/sensor/fail2ban_${sensor}/config" \
    -m "{
      \"name\": \"${friendly}\",
      \"state_topic\": \"${BASE_PREFIX}/${sensor}\",
      \"unique_id\": \"fail2ban_${sensor}\",
      \"icon\": \"${icon}\",
      \"device\": {
        \"identifiers\": [\"fail2ban_device\"],
        \"name\": \"fail2ban\",
        \"manufacturer\": \"Fail2Ban\"
      }
    }" \
    -r
}

publish_discovery "currently_failed"  "fail2ban currently_failed"  "mdi:alert-circle-outline"
publish_discovery "total_failed"      "fail2ban total_failed"      "mdi:counter"
publish_discovery "currently_banned"  "fail2ban currently_banned"  "mdi:block-helper"
publish_discovery "total_banned"      "fail2ban total_banned"      "mdi:shield-home"
