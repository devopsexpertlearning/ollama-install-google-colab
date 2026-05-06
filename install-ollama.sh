# =========================
# 0. Install dependencies
# =========================
set -e

echo "🔧 Installing dependencies..."
apt-get update -qq
apt-get install -y zstd curl wget

# =========================
# 1. Install Ollama
# =========================
echo "📦 Installing Ollama..."
curl -fsSL https://ollama.com/install.sh | sh

# =========================
# 2. Start Ollama (with logs)
# =========================
echo "🚀 Starting Ollama..."
pkill ollama || true

OLLAMA_HOST=0.0.0.0 ollama serve > ollama.log 2>&1 &
OLLAMA_PID=$!

# Stream logs in background
tail -f ollama.log &
LOG_PID=$!

# =========================
# 3. Wait until API ready
# =========================
echo "⏳ Waiting for Ollama API..."
for i in {1..20}; do
  if curl -s http://127.0.0.1:11434/api/tags >/dev/null; then
    echo "✅ Ollama is ready"
    break
  fi
  sleep 2
done

# =========================
# 4. Pull model (with progress)
# =========================
echo "📥 Pulling model (this may take time)..."
ollama pull gemma4:latest

# =========================
# 5. Install Cloudflare
# =========================
echo "🌐 Installing Cloudflare tunnel..."
wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cloudflared
chmod +x cloudflared

# =========================
# 6. Start tunnel (with logs)
# =========================
echo "🌍 Starting tunnel..."
pkill cloudflared || true

./cloudflared tunnel \
  --url http://127.0.0.1:11434 \
  --http-host-header="localhost:11434" \
  > tunnel.log 2>&1 &

# =========================
# 7. Wait for URL
# =========================
echo "🔎 Fetching public URL..."
for i in {1..10}; do
  URL=$(grep -o 'https://[-a-zA-Z0-9]*\.trycloudflare\.com' tunnel.log | head -n 1)
  if [ ! -z "$URL" ]; then
    echo "🌐 PUBLIC URL: $URL"
    break
  fi
  sleep 2
done

# =========================
# 8. Health check
# =========================
echo "🧪 Testing API..."
curl -s http://127.0.0.1:11434/api/tags

echo ""
echo "🎉 Setup complete!"
echo "👉 Test:"
echo "curl $URL/api/tags"
