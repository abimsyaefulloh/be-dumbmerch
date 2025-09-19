// === BE STAGING (tanpa clone di server) ===
def branch        = "staging"
def server        = "Abim22@103.175.220.38"
def cred          = "finaltask"                 // SSH credentials ID ke server
def directory     = "/home/Abim22/be-dumbmerch"

def image         = "be-dumbmerch-staging"
def container     = "be-dumbmerch-staging"
def host_port     = "5002"
def app_port      = "5000"

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

    stage('Docker Clean') {
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
              docker build -t ${image} .
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
              # .env minimal (ISI VAR DB DI SINI KALAU PERLU)
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
                ${image}
            '
          """
        }
      }
    }
  }
}

