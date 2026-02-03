#!/bin/bash
# Script de listing COMPLET de tous les services actifs

cat > /tmp/list-all-services.sh << 'EOF'
#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   LISTE COMPLÈTE DES SERVICES ACTIFS${NC}"
echo -e "${BLUE}========================================${NC}\n"

# ========================================
# 1. SERVICES SYSTEMD ACTIFS
# ========================================
echo -e "${YELLOW}[1/8]${NC} Services systemd en cours d'exécution:"
echo "================================================================"
systemctl list-units --type=service --state=running --no-pager --no-legend | awk '{print $1, $2, $3, $4}' | column -t
echo ""

# ========================================
# 2. TIMERS SYSTEMD ACTIFS
# ========================================
echo -e "${YELLOW}[2/8]${NC} Timers systemd actifs (équivalent cron):"
echo "================================================================"
systemctl list-timers --all --no-pager
echo ""

# ========================================
# 3. TOUS LES SERVICES (même inactifs)
# ========================================
echo -e "${YELLOW}[3/8]${NC} Liste de TOUS les services (actifs + inactifs):"
echo "================================================================"
systemctl list-unit-files --type=service --no-pager | grep -E "enabled|disabled|static" | column -t | head -50
echo "... (liste tronquée, voir le fichier complet)"
echo ""

# ========================================
# 4. SERVICES EN ÉCOUTE (PORTS)
# ========================================
echo -e "${YELLOW}[4/8]${NC} Services en écoute sur des ports:"
echo "================================================================"
echo -e "${GREEN}Proto${NC} | ${GREEN}Port${NC} | ${GREEN}Process${NC}"
echo "----------------------------------------------------------------"
sudo netstat -tulpn | grep LISTEN | awk '{print $1, $4, $7}' | column -t
echo ""

# ========================================
# 5. PROCESSUS AVEC CONNEXIONS ÉTABLIES
# ========================================
echo -e "${YELLOW}[5/8]${NC} Processus avec connexions réseau actives:"
echo "================================================================"
sudo ss -tunap state established | grep -v "State" | awk '{print $6, $5, $7}' | column -t
echo ""

# ========================================
# 6. PROCESSUS DÉMONS (background)
# ========================================
echo -e "${YELLOW}[6/8]${NC} Processus démons en arrière-plan:"
echo "================================================================"
ps aux | awk '$8 ~ /D|S/ && $1 != "USER"' | grep -v "\[" | head -30
echo ""

# ========================================
# 7. CRONS ACTIFS (tous utilisateurs)
# ========================================
echo -e "${YELLOW}[7/8]${NC} Tâches cron actives:"
echo "================================================================"

echo -e "${GREEN}=== CRON ROOT ===${NC}"
sudo crontab -l 2>/dev/null || echo "Aucun cron root"
echo ""

echo -e "${GREEN}=== CRON USER0 ===${NC}"
crontab -l 2>/dev/null || echo "Aucun cron user0"
echo ""

echo -e "${GREEN}=== /etc/crontab ===${NC}"
cat /etc/crontab | grep -v "^#" | grep -v "^$"
echo ""

echo -e "${GREEN}=== /etc/cron.d/ ===${NC}"
for f in /etc/cron.d/*; do
    if [ -f "$f" ]; then
        echo "--- $f ---"
        cat "$f" | grep -v "^#" | grep -v "^$"
    fi
done
echo ""

# ========================================
# 8. SERVICES SUSPECTS PAR NOM
# ========================================
echo -e "${YELLOW}[8/8]${NC} Analyse des services suspects (noms courts/inhabituels):"
echo "================================================================"

SUSPECT_SERVICES=$(systemctl list-units --type=service --state=running --no-pager --no-legend | awk '{print $1}' | grep -E "^[a-z]{1,4}\.|^[0-9]")

if [ -n "$SUSPECT_SERVICES" ]; then
    echo -e "${RED}Services avec noms suspects détectés:${NC}"
    echo "$SUSPECT_SERVICES"
    echo ""
    
    for svc in $SUSPECT_SERVICES; do
        echo -e "${YELLOW}--- Détails de $svc ---${NC}"
        systemctl status "$svc" --no-pager | head -10
        echo ""
    done
else
    echo -e "${GREEN}Aucun service suspect par nom${NC}"
fi

echo ""

# ========================================
# RÉSUMÉ
# ========================================
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   RÉSUMÉ${NC}"
echo -e "${BLUE}========================================${NC}"

TOTAL_RUNNING=$(systemctl list-units --type=service --state=running --no-pager --no-legend | wc -l)
TOTAL_ENABLED=$(systemctl list-unit-files --type=service --state=enabled --no-pager --no-legend | wc -l)
TOTAL_TIMERS=$(systemctl list-timers --all --no-pager --no-legend | wc -l)
TOTAL_LISTENING=$(sudo netstat -tulpn | grep LISTEN | wc -l)
TOTAL_ESTABLISHED=$(sudo ss -tunap state established | grep -v "State" | wc -l)

echo -e "${GREEN}Services actifs:${NC} $TOTAL_RUNNING"
echo -e "${GREEN}Services activés au démarrage:${NC} $TOTAL_ENABLED"
echo -e "${GREEN}Timers actifs:${NC} $TOTAL_TIMERS"
echo -e "${GREEN}Ports en écoute:${NC} $TOTAL_LISTENING"
echo -e "${GREEN}Connexions établies:${NC} $TOTAL_ESTABLISHED"

echo -e "\n${BLUE}Fichier complet sauvegardé dans:${NC} /tmp/services-full-list.txt"

EOF

chmod +x /tmp/list-all-services.sh
sudo /tmp/list-all-services.sh | tee /tmp/services-full-list.txt
