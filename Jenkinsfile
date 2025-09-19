// === BE PRODUCTION (tanpa clone di server, aman bareng staging) ===
def branch        = "production"
def server        = "Abim22@103.175.220.38"
def cred          = "finaltask"                       // Jenkins SSH Credentials ID

// Pakai direktori terpisah dari staging!
def directory     = "/opt/be-dumbmerch-prod"

def image         = "be-dumbmerch-prod"               // beda dari staging
def container     = "be-dumbmerch-prod"               // beda dari staging
def host_port     = "5000"                            // port host untuk produksi
def app_port      = "5000"                            // port di dalam container

pipeline {
  agent any
  options { timestamps() }

  stages {
    stage('Checkout (SCM)') { steps { checkout scm } }

    stage('Repo Sync (copy workspace -> server)') {
      steps {
        sshagent([cred]) {
          sh """
            set -e
            ssh -o StrictHostKeyChecking=no ${server} 'mkdir -p ${directory}'
            # kirim isi workspace ke server, exclude .git biar ringan
            tar --exclude='.git' -C "${WORKSPACE}" -cf - . | \
              ssh -o StrictHostKeyChecking=no ${server} 'tar -C ${directory} -xf -'
          """
        }
      }
    }

    stage('Docker Clean (only PROD container/image)') {
      steps {
        sshagent([cred]) {
          sh """
            ssh -o StrictHostKeyChecking=no ${server} '
              docker rm -f ${container} >/dev/null 2>&1 || true
              docker rmi -f ${image}    >/dev/null 2>&1 || true
            '
          """
        }
      }
    }

    stage('Docker Build') {
      steps {
        sshagent([cred]) {
          sh """
            ssh -o StrictHostKeyChecking=no ${server} '
              set -e
              cd ${directory}
              docker build -t ${image}:${branch} .
              # tag latest-prod optional
              docker tag ${image}:${branch} ${image}:latest
            '
          """
        }
      }
    }

    stage('Docker Run') {
      steps {
        sshagent([cred]) {
          sh """
            ssh -o StrictHostKeyChecking=no ${server} '
              set -e
              # .env PRODUKSI — isi/ubah sesuai kebutuhanmu
              cat > ${directory}/.env <<EOT
PORT=${app_port}
# DB_HOST=...
# DB_PORT=5432
# DB_USER=abim
# DB_PASSWORD=abim123
# DB_NAME=dumbmerch
EOT
              docker rm -f ${container} >/dev/null 2>&1 || true
              docker run -d --name ${container} \\
                -p ${host_port}:${app_port} \\
                -v ${directory}/.env:/app/.env:ro \\
                --restart unless-stopped \\
                ${image}:${branch}
            '
          """
        }
      }
    }
  }
}
