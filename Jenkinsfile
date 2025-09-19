// === BE PRODUCTION (tanpa clone di server, pakai HOME, connect ke DB) ===
def branch     = "production"                         // ganti ke "main" kalau branch utama main
def server     = "Abim22@103.175.220.38"              // Backend server
def cred       = "finaltask"                          // Jenkins SSH Credentials ID

def directory  = "/home/Abim22/be-dumbmerch-prod"     // folder KHUSUS prod (beda dari staging)
def image      = "be-dumbmerch-prod"                  // image prod
def container  = "be-dumbmerch-prod"                  // container prod
def host_port  = "5000"                               // port host untuk prod
def app_port   = "5000"                               // port di dalam container

// DB + network
def net        = "dumbmerch-prod-net"                 // user-defined Docker network
def db_name    = "dumbmerch"
def db_user    = "abim"
def db_pass    = "abim123"
def db_port    = "5432"
def db_host    = "be_db"                              // nama container DB-mu saat ini

pipeline {
  agent any
  options { timestamps() }

  stages {
    stage('Checkout (SCM)') {
      steps { checkout scm }
    }

    stage('Repo Sync (workspace → server)') {
      steps {
        withEnv(["SERVER=${server}", "DIRECTORY=${directory}"]) {
          sshagent([cred]) {
            sh '''set -e
ssh -o StrictHostKeyChecking=no "$SERVER" "mkdir -p $DIRECTORY"
# kirim source dari Jenkins workspace (tanpa .git & node_modules)
tar --exclude='.git' --exclude='node_modules' -C "$WORKSPACE" -cf - . | \
  ssh -o StrictHostKeyChecking=no "$SERVER" "tar -C $DIRECTORY -xf -"
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
ssh -o StrictHostKeyChecking=no "$SERVER" bash -lc "
  set -e
  cd $DIRECTORY
  docker build -t $IMAGE:$BRANCH .
  docker tag  $IMAGE:$BRANCH $IMAGE:latest
"
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
          "BRANCH=${branch}",
          "NET=${net}",
          "DB_HOST=${db_host}",
          "DB_PORT=${db_port}",
          "DB_USER=${db_user}",
          "DB_PASSWORD=${db_pass}",
          "DB_NAME=${db_name}",
        ]) {
          sshagent([cred]) {
            sh '''set -e
ssh -o StrictHostKeyChecking=no "$SERVER" bash -lc "
  set -e

  # 0) Pastikan network ada & sambungkan DB ke network tsb (abaikan error kalau sudah)
  docker network inspect $NET >/dev/null 2>&1 || docker network create $NET
  docker network connect $NET $DB_HOST >/dev/null 2>&1 || true

  # 1) Stop container prod lama (kalau ada)
  docker rm -f $CONTAINER >/dev/null 2>&1 || true

  # 2) Jika ada container LAIN yang publish port $HOST_PORT, hapus juga (hindari 'port is already allocated')
  CONFLICTS=$(docker ps --filter "publish=$HOST_PORT" -q)
  if [ -n "$CONFLICTS" ]; then
    echo "Removing containers on port $HOST_PORT: $CONFLICTS"
    docker rm -f $CONFLICTS || true
  fi

  # 3) Tulis .env produksi (kalau app-mu membaca .env)
  cat > $DIRECTORY/.env <<EOT
PORT=$APP_PORT
DB_HOST=$DB_HOST
DB_PORT=$DB_PORT
DB_USER=$DB_USER
DB_PASSWORD=$DB_PASSWORD
DB_NAME=$DB_NAME
EOT

  # 4) Jalankan BE prod di network yg sama dgn DB
  docker run -d --name $CONTAINER \\
    --network $NET \\
    -p $HOST_PORT:$APP_PORT \\
    -v $DIRECTORY/.env:/app/.env:ro \\
    --restart unless-stopped \\
    $IMAGE:$BRANCH
"
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
