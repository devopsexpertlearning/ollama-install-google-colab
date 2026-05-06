# 🚀 Ollama on Google Colab with Cloudflare Tunnel

Run **Ollama LLMs** inside Google Colab and expose them to the internet using Cloudflare Tunnel.

This project provides a **fully automated setup script** that:

* Installs Ollama
* Downloads a model
* Starts the API server
* Exposes it via a public URL

---

## 📌 Features

* ⚡ One-command setup
* 🌐 Public API via Cloudflare Tunnel
* 🔄 Automatic health checks
* 📜 Real-time logging
* 🧠 Supports any Ollama model
* 🧪 Ready for API testing

---

## 🛠️ Requirements

* Google Colab account
* Internet connection
* (Optional) GPU runtime for better performance

---

## 🚀 Quick Start

### 1. Open Google Colab

Create a new notebook and paste the script below.

---

### 2. Run Setup Script

```bash
# =========================
# 0. Install dependencies
# =========================
set -e

apt-get update -qq
apt-get install -y zstd curl wget

# =========================
# 1. Install Ollama
# =========================
curl -fsSL https://ollama.com/install.sh | sh

# =========================
# 2. Start Ollama
# =========================
pkill ollama || true

OLLAMA_HOST=0.0.0.0 ollama serve > ollama.log 2>&1 &
sleep 10

# =========================
# 3. Verify API
# =========================
curl http://127.0.0.1:11434/api/tags

# =========================
# 4. Pull Model
# =========================
ollama pull gemma4:latest

# =========================
# 5. Install Cloudflare Tunnel
# =========================
wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cloudflared
chmod +x cloudflared

# =========================
# 6. Start Tunnel
# =========================
pkill cloudflared || true

nohup ./cloudflared tunnel \
  --url http://127.0.0.1:11434 \
  --http-host-header="localhost:11434" \
  > tunnel.log 2>&1 &

sleep 5

# =========================
# 7. Get Public URL
# =========================
grep -o 'https://[-a-zA-Z0-9]*\.trycloudflare\.com' tunnel.log | head -n 1
```

---

## 🌐 Example Output

```
https://abcd-xyz.trycloudflare.com
```

---

## 🧪 API Usage

### List Models

```bash
curl https://<YOUR-URL>/api/tags
```

---

### Generate Text

```bash
curl https://<YOUR-URL>/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gemma4:latest",
    "prompt": "Hello from internet",
    "stream": false
  }'
```

---

## 📂 Project Structure

```
.
├── README.md
└── colab_script.sh
```

---

## ⚠️ Limitations

* ⏱️ Colab sessions expire
* 🔓 No authentication (public endpoint)
* 🌐 Cloudflare quick tunnels may be unstable
* 🐢 CPU inference is slow without GPU

---

## 🔐 Security Notice

Do NOT expose sensitive workloads using this setup.

For production:

* Use a VM or Kubernetes cluster
* Add authentication (JWT, API key)
* Use HTTPS with a custom domain

---

## 🚀 Production Alternatives

* Deploy Ollama on a VM (OCI / AWS / GCP)
* Use Kubernetes with Ingress + TLS
* Use persistent storage for models

---

## 🤝 Contributing

Pull requests are welcome! Feel free to improve scripts, add features, or fix bugs.

---

## 📜 License

MIT License

---

## ⭐ Support

If you find this useful:

* ⭐ Star the repo
* 🍴 Fork it
* 🧑‍💻 Share with others

---

## 💬 Author

Maintained by **DevOps Expert Learning**

---
