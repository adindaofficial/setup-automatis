#!/usr/bin/env bash
set -e

echo "=== Setup SSH GitHub Otomatis ==="

# Input user
read -p "Masukkan username Git: " GIT_USERNAME
read -p "Masukkan email GitHub: " GIT_EMAIL

# Masuk ke folder .ssh
mkdir -p ~/.ssh
chmod 700 ~/.ssh
cd ~/.ssh

KEY_FILE="$HOME/.ssh/id_rsa"

# Generate SSH key jika belum ada
if [ -f "$KEY_FILE" ]; then
  echo "SSH key sudah ada, skip generate..."
else
  echo "Membuat SSH key..."
  ssh-keygen -t rsa -b 4096 -C "$GIT_EMAIL" -f "$KEY_FILE" -N ""
fi

# Konfigurasi git
echo "Setting git config..."
git config --global user.name "$GIT_USERNAME"
git config --global user.email "$GIT_EMAIL"

# Jalankan ssh-agent
echo "Menjalankan ssh-agent..."
eval "$(ssh-agent -s)"

# Tambahkan key
echo "Menambahkan SSH key..."
ssh-add "$KEY_FILE"

# Tampilkan public key
echo ""
echo "===== COPY SSH KEY INI KE GITHUB ====="
cat "$KEY_FILE.pub"
echo "======================================"
echo "GitHub → Settings → SSH and GPG keys → New SSH key"
echo ""

# Tunggu user
read -p "Tekan ENTER setelah SSH key ditambahkan ke GitHub..."

# Test koneksi
echo "Testing SSH ke GitHub..."
set +e
ssh -T git@github.com
STATUS=$?
set -e

echo ""
if [ $STATUS -eq 1 ] || [ $STATUS -eq 0 ]; then
  echo "✅ Berhasil: SSH sudah terhubung ke GitHub"
else
  echo "❌ Gagal: cek kembali SSH key di GitHub"
fi
