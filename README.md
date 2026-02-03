# Linux Services Full Audit

Script Bash d’audit complet des services, timers, ports, connexions et tâches planifiées sur un système Linux utilisant systemd. Il s’appuie sur `systemctl`, `netstat`, `ss`, `ps` et la configuration cron pour fournir une vue d’ensemble des services et de leur exposition réseau.

## Fonctionnalités

- **Services systemd actifs** : liste les unités `service` en cours d’exécution.
- **Timers systemd** : affiche tous les timers actifs (équivalents modernes des crons) via `systemctl list-timers`.
- **Tous les services** : extrait les services `enabled/disabled/static` et en affiche un aperçu.
- **Ports en écoute** : montre les services à l’écoute sur des ports via `netstat -tulpn`.
- **Connexions établies** : liste les connexions réseau actives avec `ss -tunap state established`.
- **Processus démons** : repère certains processus tournant en arrière-plan (états `D` ou `S`).
- **Crons actifs** : affiche les crontabs de root, de l’utilisateur courant, `/etc/crontab` et `/etc/cron.d/`.
- **Services suspects** : tente de détecter des services avec des noms courts ou atypiques (potentiellement suspects) et affiche leur `systemctl status`.

## Prérequis

- Distribution Linux avec **systemd** et `systemctl`.
- Utilitaires : `netstat` (paquet `net-tools`), `ss`, `ps`, `column`, `grep`, `awk`.
- Droits **sudo** pour certaines commandes (netstat, ss, crontab root).
- Bash 4+.

## Installation

1. Cloner le dépôt :

   ```bash
   git clone https://github.com/ledokter/linux-services-full-audit.git
   cd linux-services-full-audit
Copier le script dans le dépôt et le rendre exécutable :

bash
chmod +x list-all-services.sh
Utilisation
Exécution simple :

bash
sudo ./list-all-services.sh
Ce script :

Crée/écrase /tmp/list-all-services.sh contenant la logique principale.

Lance ce script avec sudo et duplique la sortie vers /tmp/services-full-list.txt grâce à tee.

Affiche un résumé final (nombre de services actifs, activés au boot, timers, ports en écoute, connexions établies).

Le fichier /tmp/services-full-list.txt contient le rapport complet pour consultation ou archivage.

Exemple de sortie
text
========================================
   LISTE COMPLÈTE DES SERVICES ACTIFS
========================================

[1/8] Services systemd en cours d'exécution:
...
[8/8] Analyse des services suspects (noms courts/inhabituels):
...
RÉSUMÉ
Services actifs: 73
Services activés au démarrage: 52
Timers actifs: 8
Ports en écoute: 12
Connexions établies: 5

Fichier complet sauvegardé dans: /tmp/services-full-list.txt
Notes et recommandations
L’analyse des noms « suspects » est heuristique et peut générer des faux positifs sur des services légitimes aux noms courts.

Le script ne modifie pas la configuration système ; il se contente de lister et de synthétiser les informations pour l’audit.

Vous pouvez automatiser son exécution régulière via cron ou un timer systemd pour suivre l’évolution de vos services dans le temps.


Auteur : ledokter

Aucun site web ni adresse email de contact fournis pour ce projet.

Licence : MIT
