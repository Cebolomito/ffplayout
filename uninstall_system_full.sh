#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

echo "[+] 1. Zerando a tabela de autenticação no banco existente..."
DB_PATH="/usr/share/ffplayout/db/ffplayout.db"

if [ -f "$DB_PATH" ]; then
    # Zera os usuários e limpa os arquivos temporários de memória no próprio arquivo
    python3 -c "import sqlite3; con=sqlite3.connect('$DB_PATH'); con.execute('DELETE FROM auth_user;'); con.execute('VACUUM;'); con.commit(); con.close()" 2>/dev/null || true
    echo "[+] Tabela auth_user zerada e banco limpo no local original."
fi

echo "[+] 2. Encerrando processos e serviços..."
systemctl stop ffplayout 2>/dev/null || true
killall -9 ffplayout 2>/dev/null || true
fuser -k 8787/tcp 2>/dev/null || true

echo "[+] 3. Removendo completamente banco de dados, storage (tv-media), playlists, logs e resíduos..."
rm -rf /usr/share/ffplayout
rm -rf /var/log/ffplayout
rm -rf /etc/ffplayout
rm -rf /var/cache/ffplayout
rm -rf /run/ffplayout
rm -rf /root/.sqlite_history
rm -rf /home/*/.sqlite_history

# Apaga tudo dentro de /var/lib/ffplayout, incluindo tv-media e playlists
rm -rf /var/lib/ffplayout

echo "[+] 4. Expurgando pacote e resíduos do dpkg/systemd..."
apt-get purge -y ffplayout 2>/dev/null || true
dpkg --purge --force-all ffplayout 2>/dev/null || true
apt-get autoremove -y --purge 2>/dev/null || true

rm -f /etc/systemd/system/multi-user.target.wants/ffplayout.service
rm -f /etc/systemd/system/ffplayout.service
rm -f /usr/lib/systemd/system/ffplayout.service
rm -f /lib/systemd/system/ffplayout.service
rm -rf /var/lib/systemd/deb-systemd-helper-enabled/ffplayout*

echo "[+] 5. Recriando usuário de sistema ffpu..."
userdel -f -r ffpu 2>/dev/null || true
groupdel ffpu 2>/dev/null || true
addgroup --system ffpu 2>/dev/null || true
adduser --system --ingroup ffpu --no-create-home ffpu 2>/dev/null || true

echo "[+] 6. Recarregando daemons e liberando cache da memória..."
systemctl daemon-reload
systemctl reset-failed
sync && echo 3 > /proc/sys/vm/drop_caches

echo "[+] Limpeza total concluída! Banco zerado inicialmente e depois tudo apagado (banco, storage e playlists). Pronto para o dpkg -i."
