// === BE STAGING (simple seperti wayshub) ===
def branch     = "main"
def remote     = "origin"
def directory  = "/home/Abim22/be-dumbmerch"       // jangan pakai ~
def server     = "Abim22@103.175.220.38"
def cred       = "finaltask"

def image      = "be-dumbmerch-staging"
def container  = "be-dumbmerch-staging"
def host_port  = "5002"
def app_port   = "5000"
def repo_url   = "https://github.com/abimsyaefulloh/be-dumbmerch.git"

pipeline {
  agent any
  options { timestamps() }

  stages {
    stage('Repo Sync') {
      steps {
        sshagent([cred]) {
          sh """
            ssh -o StrictHostKeyChecking=no ${server} << 'EOF'
            set -euo pipefail
            if [ -d "${directory}/.git" ]; then
              cd ${directory}
              git fetch ${remote} ${branch}
              git checkout -f ${branch}
              git reset --hard ${remote}/${branch}
            } else {
              rm -rf ${directory}
              git clone -b ${branch} ${repo_url} ${directory}
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
            ssh -o StrictHostKeyChecking=no ${server} << 'EOF'
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
            ssh -o StrictHostKeyChecking=no ${server} << 'EOF'
            set -euo pipefail
            cd ${directory}
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
            ssh -o StrictHostKeyChecking=no ${server} << 'EOF'
            set -euo pipefail
            # .env minimal agar backend-mu nggak panic
            cat > ${directory}/.env <<EOT
PORT=${app_port}
DB_HOST=dumbmerch-db
DB_PORT=5432
DB_USER=abim
DB_PASSWORD=abim123
DB_NAME=dumbmerch
EOT

            docker rm -f ${container} || true
            docker run -d --name ${container} \\
              --restart unless-stopped \\
              -v ${directory}/.env:/app/.env:ro \\
              -p ${host_port}:${app_port} \\
              ${image}
            EOF
          """
        }
      }
    }
  }
}
