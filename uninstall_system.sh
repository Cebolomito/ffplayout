#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

echo "[+] 1. Encerrando processos e serviços..."
systemctl stop ffplayout 2>/dev/null || true
killall -9 ffplayout 2>/dev/null || true
fuser -k 8787/tcp 2>/dev/null || true

echo "[+] 2. Removendo completamente banco de dados, storage (tv-media), playlists, logs e resíduos..."
rm -rf /usr/share/ffplayout
rm -rf /var/log/ffplayout
rm -rf /etc/ffplayout
rm -rf /var/cache/ffplayout
rm -rf /run/ffplayout
rm -rf /root/.sqlite_history
rm -rf /home/*/.sqlite_history

echo "[+] 3. Expurgando pacote e resíduos do dpkg/systemd..."
apt-get purge -y ffplayout 2>/dev/null || true
dpkg --purge --force-all ffplayout 2>/dev/null || true
apt-get autoremove -y --purge 2>/dev/null || true

rm -f /etc/systemd/system/multi-user.target.wants/ffplayout.service
rm -f /etc/systemd/system/ffplayout.service
rm -f /usr/lib/systemd/system/ffplayout.service
rm -f /lib/systemd/system/ffplayout.service
rm -rf /var/lib/systemd/deb-systemd-helper-enabled/ffplayout*
rm -rf /var/lib/ffplayout

echo "[+] 4. Deletando usuário de sistema ffpu..."
userdel -f -r ffpu 2>/dev/null || true

echo "[+] 5. Recarregando daemons"
systemctl daemon-reload

echo "[+] Limpeza total concluída! Banco zerado inicialmente e depois tudo apagado (banco, storage e playlists). Pronto para o dpkg -i."
