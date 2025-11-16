🔒 Fail2Ban MQTT Publisher
🟦 Intégration Fail2Ban → MQTT → Home Assistant (Auto-Discovery)

Ce projet permet de publier automatiquement l’état de Fail2Ban dans MQTT, avec un support complet de Home Assistant MQTT Auto-Discovery, afin d’obtenir des capteurs prêts à l’emploi :

🔴 currently_failed : Tentatives d'échec en cours

🔢 total_failed : Total des échecs depuis le démarrage

🚫 currently_banned : IP bannies actuellement

🛡 total_banned : Nombre total d’IP bannies

Grâce à MQTT Discovery, les capteurs apparaissent automatiquement dans Home Assistant sous un seul device nommé fail2ban.

✨ Fonctionnalités
✔ Publie les données Fail2Ban via MQTT (avec valeurs retained)
✔ Full Home Assistant MQTT Auto-Discovery
✔ Compatibilité totale IPv4 / IPv6
✔ Aucun redémarrage Fail2Ban nécessaire
✔ Aucun module Python – entièrement en Bash
✔ Icônes MDI inclus pour un affichage propre
✔ Device unique "fail2ban" dans Home Assistant
✔ Fonctionne avec tous les jails (via variable JAIL)
📦 Exemple des capteurs créés dans Home Assistant
Capteur	Topic MQTT	Icône MDI
currently_failed	fail2ban/traefik-login/currently_failed	mdi:alert-circle-outline
total_failed	fail2ban/traefik-login/total_failed	mdi:counter
currently_banned	fail2ban/traefik-login/currently_banned	mdi:block-helper
total_banned	fail2ban/traefik-login/total_banned	mdi:shield-home
⚙️ Installation
1️⃣ Copier le script dans /usr/local/bin/fail2ban_mqtt.sh
sudo nano /usr/local/bin/fail2ban_mqtt.sh


📌 Rends-le exécutable :

sudo chmod +x /usr/local/bin/fail2ban_mqtt.sh

🕒 Automatisation (cron)

Exécuter le script toutes les minutes :

sudo crontab -e


Ajouter :

* * * * * /usr/local/bin/fail2ban_mqtt.sh >/dev/null 2>&1

📡 Configuration Home Assistant (automatique)

Aucune configuration manuelle !
Les capteurs apparaissent automatiquement grâce à MQTT Auto-Discovery.

Les entités seront regroupées sous :

Appareils → fail2ban

📁 Structure MQTT publiée
homeassistant/
└── sensor/
    └── fail2ban_<metric>/config
fail2ban/<jail>/currently_failed
fail2ban/<jail>/total_failed
fail2ban/<jail>/currently_banned
fail2ban/<jail>/total_banned

📜 Licence

MIT — utilisation libre.
