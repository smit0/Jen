stage('Deploy Docker') {
            steps {
                sh """
                ssh \
                -i /var/lib/jenkins/.ssh/id_ed25519 \
                -o StrictHostKeyChecking=no \
                ${APP_USER}@${APP_SERVER} << 'EOF'

                set -e

                cd ${DEPLOY_DIR}

                BUILD_NAME=\$(TZ=Asia/Kolkata date +%d-%m-%Y-%H-%M-%S)

                IMAGE=nivi-\${BUILD_NAME}
                CONTAINER=\${IMAGE}-container

                echo "=================================="
                echo "Building Docker Image : \${IMAGE}"
                echo "=================================="

                docker build -t \${IMAGE} .

                echo "Starting new container..."

                docker run -d \
                    --restart unless-stopped \
                    --name \${CONTAINER} \
                    -p 80:80 \
                    \${IMAGE}

                echo "Cleaning old containers (Keeping latest 5)..."

                # 1. List all nivi- containers ordered from newest to oldest
                # 2. Skip the first 5 lines (the 5 newest containers) using tail -n +6
                # 3. Delete any remaining older containers
                docker ps -a \
                    --filter "name=nivi-" \
                    --format "{{.CreatedAt}} {{.Names}}" \
                    | sort -r \
                    | awk '{print \$NF}' \
                    | tail -n +6 \
                    | while read c
                do
                    [ -n "\$c" ] && docker rm -f "\$c" || true
                done

                echo "Cleaning old images (Keeping latest 5)..."

                docker images \
                    --format "{{.CreatedAt}} {{.Repository}}:{{.Tag}}" \
                    | grep "^nivi-" \
                    | sort -r \
                    | awk '{print \$NF}' \
                    | tail -n +6 \
                    | while read img
                do
                    [ -n "\$img" ] && docker rmi -f "\$img" || true
                done

                echo "Deployment Completed Successfully."

                EOF
                """
            }
        }
