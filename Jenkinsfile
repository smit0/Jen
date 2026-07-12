pipeline {

    agent any

    environment {

        APP_SERVER = "172.18.20.10"
        APP_USER = "opc"

        APP_DIR = "/home/opc/docker-app"

        TZ = "Asia/Kolkata"

    }

    stages {

        stage('Checkout') {

            steps {

                checkout scm

            }

        }

        stage('Deploy Application') {

            steps {

                sh """

ssh -o StrictHostKeyChecking=no ${APP_USER}@${APP_SERVER} '

cd ${APP_DIR}

echo "Updating Source"

git pull

BUILD_NAME=\$(TZ=Asia/Kolkata date +%d-%m-%Y-%H-%M-%S)

IMAGE=nivi-\$BUILD_NAME

CONTAINER=\${IMAGE}-container

echo "Building Docker Image"

docker build -t \$IMAGE .

echo "Stopping Running Containers"

docker ps -a \
--filter "name=nivi-" \
--format "{{.Names}}" \
| while read c
do
docker rm -f \$c || true
done

echo "Starting Container"

docker run -d \
-p 80:80 \
--restart unless-stopped \
--name \$CONTAINER \
\$IMAGE

echo "Removing old Containers"

docker ps -a \
--filter "name=nivi-" \
--format "{{.CreatedAt}} {{.Names}}" \
| sort -r \
| awk "{print \\$NF}" \
| tail -n +6 \
| while read c
do
docker rm -f \$c || true
done

echo "Removing old Images"

docker images \
--format "{{.CreatedAt}} {{.Repository}}" \
| grep "nivi-" \
| sort -r \
| awk "{print \\$NF}" \
| tail -n +6 \
| while read i
do
docker rmi -f \$i || true
done

docker ps

'

"""

            }

        }

    }

}
