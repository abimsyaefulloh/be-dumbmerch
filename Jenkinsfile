// === BE STAGING (simple seperti wayshub) ===
def branch     = "main"
def remote     = "origin"
def repo_url   = "https://github.com/abimsyaefulloh/be-dumbmerch.git"

def server     = "Abim22@103.175.220.38"   // GatewayServer (BE)
def cred       = "finaltask"               // Jenkins Credentials ID (SSH)
def directory  = "/home/Abim22/be-dumbmerch"  // JANGAN pakai ~

def image      = "be-dumbmerch-staging"
def container  = "be-dumbmerch-staging"
def host_port  = "5002"   // sesuai Nginx staging
def app_port   = "5000"   // port di dalam container

pipeline {
  agent any
  options { timestamps() }

  stages {
    stage('Repo Sync') {
      steps {
        sshagent([cred]) {
          sh """
            ssh -o StrictHostKeyChecking=no ${server} << EOF
set -euo pipefail
if [ -d "${directory}/.git" ]; then
  cd "${directory}"
  git fetch ${remote} ${branch}
  git checkout -f ${branch}
  git reset --hard ${remote}/${branch}
else
  rm -rf "${directory}"
  git clone -b ${branch} ${repo_url} "${directory}"
fi
EOF
          """
        }
      }
    }

    stage('Docker Clean') {
      steps {
        sshagent([cred]) {
          sh """
            ssh -o StrictHostKeyChecking=no ${server} << EOF
docker rm -f ${container} || true
docker rmi -f ${image} || true
EOF
          """
        }
      }
    }

    stage('Docker Build') {
      steps {
        sshagent([cred]) {
          sh """
            ssh -o StrictHostKeyChecking=no ${server} << EOF
set -euo pipefail
cd "${directory}"
docker build -t ${image} .
EOF
          """
        }
      }
    }

    stage('Docker Run') {
      steps {
        sshagent([cred]) {
          sh """
            ssh -o StrictHostKeyChecking=no ${server} << EOF
set -euo pipefail

# .env minimal agar loader .env tidak panic
cat > "${directory}/.env" <<EOT
PORT=${app_port}
# Kalau nanti pakai DB, cukup isi dan uncomment variabel di bawah:
# DB_HOST=dumbmerch-db
# DB_PORT=5432
# DB_USER=abim
# DB_PASSWORD=abim123
# DB_NAME=dumbmerch
EOT

docker rm -f ${container} || true
docker run -d --name ${container} \\
  --restart unless-stopped \\
  -v "${directory}/.env:/app/.env:ro" \\
  -p ${host_port}:${app_port} \\
  ${image}
EOF
          """
        }
      }
    }
  }
}
