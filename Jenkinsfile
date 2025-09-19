// === BE PRODUCTION (tanpa clone di server, pakai HOME) ===
def branch     = "production"                        // ganti "main" kalau branch utama main
def server     = "Abim22@103.175.220.38"
def cred       = "finaltask"

def directory  = "/home/Abim22/be-dumbmerch-prod"    // folder KHUSUS prod (beda dari staging)
def image      = "be-dumbmerch-prod"                 // image prod
def container  = "be-dumbmerch-prod"                 // container prod
def host_port  = "5000"
def app_port   = "5000"

pipeline {
  agent any
  options { timestamps() }

  stages {
    stage('Checkout (SCM)') {
      steps { checkout scm }
    }

    stage('Repo Sync (copy workspace -> server)') {
      steps {
        withEnv(["SERVER=${server}", "DIRECTORY=${directory}"]) {
          sshagent([cred]) {
            sh '''set -e
ssh -o StrictHostKeyChecking=no "$SERVER" "mkdir -p '$DIRECTORY'"
# kirim source dari workspace (tanpa .git & node_modules)
tar --exclude='.git' --exclude='node_modules' -C "$WORKSPACE" -cf - . | \
  ssh -o StrictHostKeyChecking=no "$SERVER" "tar -C '$DIRECTORY' -xf -"
'''
          }
        }
      }
    }

    stage('Docker Build (prod)') {
      steps {
        withEnv(["SERVER=${server}", "DIRECTORY=${directory}", "IMAGE=${image}", "BRANCH=${branch}"]) {
          sshagent([cred]) {
            sh '''set -e
ssh -o StrictHostKeyChecking=no "$SERVER" bash -lc '
  set -e
  cd "$DIRECTORY"
  docker build -t "$IMAGE:$BRANCH" .
  docker tag "$IMAGE:$BRANCH" "$IMAGE:latest"
'
'''
          }
        }
      }
    }

    stage('Docker Run (prod)') {
      steps {
        withEnv([
          "SERVER=${server}",
          "DIRECTORY=${directory}",
          "IMAGE=${image}",
          "CONTAINER=${container}",
          "HOST_PORT=${host_port}",
          "APP_PORT=${app_port}",
          "BRANCH=${branch}"
        ]) {
          sshagent([cred]) {
            sh '''set -e
ssh -o StrictHostKeyChecking=no "$SERVER" bash -lc '
  set -e

  # 1) stop container prod lama (kalau ada)
  docker rm -f "$CONTAINER" >/dev/null 2>&1 || true

  # 2) jika ada container lain yang publish port $HOST_PORT, hapus juga
  CONFLICTS=$(docker ps --filter "publish=$HOST_PORT" -q)
  if [ -n "$CONFLICTS" ]; then
    echo "Removing containers on port $HOST_PORT: $CONFLICTS"
    docker rm -f $CONFLICTS || true
  fi

  # 3) (opsional) tulis .env produksi jika app membaca file ini
  cat > "$DIRECTORY/.env" <<EOT
PORT=$APP_PORT
# DB_HOST=...
# DB_PORT=5432
# DB_USER=abim
# DB_PASSWORD=abim123
# DB_NAME=dumbmerch
EOT

  # 4) run container prod
  docker run -d --name "$CONTAINER" \
    -p "$HOST_PORT:$APP_PORT" \
    -v "$DIRECTORY/.env:/app/.env:ro" \
    --restart unless-stopped \
    "$IMAGE:$BRANCH"
'
'''
          }
        }
      }
    }

    stage('Smoke test') {
      steps {
        withEnv(["SERVER=${server}", "HOST_PORT=${host_port}"]) {
          sshagent([cred]) {
            sh '''set -e
ssh -o StrictHostKeyChecking=no "$SERVER" \
  "curl -fsS -I http://127.0.0.1:$HOST_PORT | head -n1"
'''
          }
        }
      }
    }
  }
}
