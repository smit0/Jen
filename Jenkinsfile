pipeline {

    agent any

    environment {
        APP_SERVER = "172.18.20.46"
        APP_USER   = "opc"
        DEPLOY_DIR = "/home/opc/docker-app"
        TZ         = "Asia/Kolkata"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Copy Application') {
            steps {
                sh """
                scp -o StrictHostKeyChecking=no -r * \
                ${APP_USER}@${APP_SERVER}:${DEPLOY_DIR}
                """
            }
        }

        stage('Deploy Docker') {
            steps {
                sh """
ssh -o StrictHostKeyChecking=no ${APP_USER}@${APP_SERVER} << 'EOF'

set -e

cd ${DEPLOY_DIR}

BUILD_NAME=\$(TZ=Asia/Kolkata date +%d-%m-%Y-%H-%M-%S)

IMAGE="nivi-\$BUILD_NAME"

CONTAINER="\$IMAGE-container"

echo "======================================="
echo "Building Image : \$IMAGE"
echo "Container Name : \$CONTAINER"
echo "======================================="

docker build -t \$IMAGE .

echo "Stopping previous running containers..."

docker ps --filter "ancestor=nivi*" -q | while read id
do
    [ -n "\$id" ] && docker stop \$id || true
done

echo "Removing old containers..."

docker ps -a --filter "name=nivi-" -q | while read id
do
    [ -n "\$id" ] && docker rm -f \$id || true
done

echo "Starting new container..."

docker run -d \
    --restart unless-stopped \
    --name \$CONTAINER \
    -p 80:80 \
    \$IMAGE

sleep 10

echo "Checking container status..."

docker ps | grep \$CONTAINER

echo "Cleaning exited containers..."

docker container prune -f

echo "Keeping latest 5 images..."

docker images \
--format "{{.Repository}} {{.Tag}} {{.CreatedAt}}" \
| grep "^nivi-" \
| sort -rk3 \
| awk 'NR>5 {print \$1":"\$2}' \
| while read img
do
    docker rmi -f \$img || true
done

echo "Deployment completed successfully."

EOF
"""
            }
        }

        stage('Verify Deployment') {
            steps {
                sh """
ssh -o StrictHostKeyChecking=no ${APP_USER}@${APP_SERVER} << 'EOF'

echo "========== Running Containers =========="
docker ps

echo
echo "========== Docker Images =========="
docker images

EOF
"""
            }
        }

    }

    post {

        success {
            echo "Deployment completed successfully."
        }

        failure {
            echo "Deployment failed."
        }

        always {
            cleanWs()
        }

    }
}