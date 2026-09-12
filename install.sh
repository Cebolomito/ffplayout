#!/bin/bash

# Atualiza o sistema
apt update && apt upgrade -y

# Garante o utilitário para adicionar PPAs e instala o FFmpeg 7
add-apt-repository -y ppa:ubuntuhandbook1/ffmpeg7
apt update
apt install ffmpeg -y 

# Baixa e instala o ffplayout no diretório correto
wget https://github.com/Cebolomito/ffplayout/releases/download/ffplayout_v2.3.0-1/ffplayout_v2.3.0-1_amd64.deb
dpkg -i ffplayout_v2.3.0-1_amd64.deb
apt install -f -y
