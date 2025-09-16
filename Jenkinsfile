// === BE STAGING ===
def BRANCH         = "main"
def REPO_URL       = "https://github.com/abimsyaefulloh/be-dumbmerch.git"
def SERVER         = "Abim22@103.175.220.38"          // GatewayServer (BE)
def CREDENTIALS_ID = "finaltask"
def REMOTE_DIR     = "/opt/be-dumbmerch"
def IMAGE_NAME     = "be-dumbmerch-staging"
def CONTAINER_NAME = "be-dumbmerch-staging"
def HOST_PORT      = "5002"                           // sesuai nginx staging
def APP_PORT       = "5000"

// DB (sesuaikan dengan compose kamu)
def DB_HOST        = "dumbmerch-db"
def DB_PORT        = "5432"
def DB_USER        = "abim"
def DB_PASSWORD    = "abim123"
def DB_NAME        = "dumbmerch"

// Network default docker compose project "be-dumbmerch"
def DOCKER_NET     = "be-dumbmerch_default"

pipeline {
  agent any
  options { timestamps() }

  stages {
    stage('Clone/Pull repo di server') {
      steps {
        sshagent([CREDENTIALS_ID]) {
          sh """
            ssh -o StrictHostKeyChecking=no ${SERVER} '
              set -e
              mkdir -p ${REMOTE_DIR}
              if git -C ${REMOTE_DIR} rev-parse --is-inside-work-tree >/dev/null 2>&1; then
                git -C ${REMOTE_DIR} fetch origin ${BRANCH}
                git -C ${REMOTE_DIR} checkout ${BRANCH}
                git -C ${REMOTE_DIR} reset --hard origin/${BRANCH}
              else
                rm -rf ${REMOTE_DIR}/*
                git clone -b ${BRANCH} ${REPO_URL} ${REMOTE_DIR}
              fi
            '
          """
        }
      }
    }

    stage('Build image BE') {
      steps {
        sshagent([CREDENTIALS_ID]) {
          sh """
            ssh -o StrictHostKeyChecking=no ${SERVER} '
              set -e
              cd ${REMOTE_DIR}
              docker build -t ${IMAGE_NAME} .
            '
          """
        }
      }
    }

    stage('Ensure network for DB') {
      steps {
        sshagent([CREDENTIALS_ID]) {
          sh """
            ssh -o StrictHostKeyChecking=no ${SERVER} '
              docker network inspect ${DOCKER_NET} >/dev/null 2>&1 || docker network create ${DOCKER_NET}
            '
          """
        }
      }
    }

    stage('Run/Restart container BE (staging)') {
      steps {
        sshagent([CREDENTIALS_ID]) {
          sh """
            ssh -o StrictHostKeyChecking=no ${SERVER} '
              set -e
              docker rm -f ${CONTAINER_NAME} || true
              docker run -d --name ${CONTAINER_NAME} \\
                --restart unless-stopped \\
                --network ${DOCKER_NET} \\
                -e DB_HOST=${DB_HOST} \\
                -e DB_PORT=${DB_PORT} \\
                -e DB_USER=${DB_USER} \\
                -e DB_PASSWORD=${DB_PASSWORD} \\
                -e DB_NAME=${DB_NAME} \\
                -p ${HOST_PORT}:${APP_PORT} \\
                ${IMAGE_NAME}
            '
          """
        }
      }
    }

    stage('Smoke test BE') {
      steps {
        sshagent([CREDENTIALS_ID]) {
          sh """
            ssh -o StrictHostKeyChecking=no ${SERVER} '
              curl -sS --max-time 5 http://127.0.0.1:${HOST_PORT}/api/v1/users | head -c 200 || exit 1
            '
          """
        }
      }
    }

    // Kalau butuh migrate manual, tinggal ubah when ke true
    stage('DB migrate (opsional)') {
      when { expression { return false } }
      steps {
        sshagent([CREDENTIALS_ID]) {
          sh """
            ssh -o StrictHostKeyChecking=no ${SERVER} '
              docker exec ${CONTAINER_NAME} ./main migrate || true
            '
          """
        }
      }
    }
  }
}
