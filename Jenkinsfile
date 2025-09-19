// === BE PRODUCTION (tanpa clone di server, pakai HOME) ===
def branch        = "production"                        // ganti ke "main" kalau branch utama main
def server        = "Abim22@103.175.220.38"
def cred          = "finaltask"

def directory     = "/home/Abim22/be-dumbmerch-prod"    // folder KHUSUS prod
def image         = "be-dumbmerch-prod"                 // image prod
def container     = "be-dumbmerch-prod"                 // container prod
def host_port     = "5000"
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
            tar --exclude='.git' --exclude='node_modules' -C "${WORKSPACE}" -cf - . | \\
              ssh -o StrictHostKeyChecking=no ${server} 'tar -C ${directory} -xf -'
          """
        }
      }
    }

    stage('Docker Build (prod)') {
      steps {
        sshagent([cred]) {
          sh """
            ssh -o StrictHostKeyChecking=no ${server} '
              set -e
              cd ${directory}
              docker build -t ${image}:${branch} .
              docker tag  ${image}:${branch} ${image}:latest
            '
          """
        }
      }
    }

    stage('Docker Run (prod)') {
      steps {
        sshagent([cred]) {
          sh """
            ssh -o StrictHostKeyChecking=no ${server} '
              set -e

              # Hentikan container prod lama (kalau ada)
              docker rm -f ${container} >/dev/null 2>&1 || true

              # Cari container lain (nama apa pun) yang publish port ${host_port} dan stop
              OLD=\$(docker ps --format "{{.ID}} {{.Names}} {{.Ports}}" \\
                 | sed -n "/0.0.0.0:${host_port}->\\|:::${host_port}->/ s/ .*//p")
              if [ -n "\\\$OLD" ]; then
                echo "Found container using port ${host_port}: \\$OLD — removing it..."
                docker rm -f "\\\$OLD" || true
              fi

              # (Opsional) tulis .env produksi
              cat > ${directory}/.env <<EOT
PORT=${app_port}
# DB_HOST=...
# DB_PORT=5432
# DB_USER=abim
# DB_PASSWORD=abim123
# DB_NAME=dumbmerch
EOT

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

    stage('Smoke test') {
      steps {
        sshagent([cred]) {
          sh """
            ssh -o StrictHostKeyChecking=no ${server} '
              set -e
              curl -fsS -I http://127.0.0.1:${host_port} | head -n1
            '
          """
        }
      }
    }
  }
}
