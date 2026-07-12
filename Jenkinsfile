pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                // Clones your git repository into the Jenkins workspace
                checkout scm
            }
        }

        stage('Copy Application') {
            steps {
                // Copies your application files over to the remote target server
                sh 'scp -i /var/lib/jenkins/.ssh/id_ed25519 -o StrictHostKeyChecking=no -r Dockerfile Jenkinsfile jenkinsfile_old opc@172.18.20.46:/home/opc/docker-app'
            }
        }

        stage('Deploy Docker') {
            steps {
                sh '''
                    ssh -i /var/lib/jenkins/.ssh/id_ed25519 -o StrictHostKeyChecking=no opc@172.18.20.46 << 'EOF'
                        # 1. Move into the directory where files were copied
                        cd /home/opc/docker-app
                        
                        echo "=================================="
                        echo "Building Docker Image..."
                        echo "=================================="
                        docker build -t nivi-image .

                        echo "=================================="
                        echo "Cycling Container Lifecycle..."
                        echo "=================================="
                        
                        # 2. Stop the running container if it exists (ignores error if it doesn't)
                        docker stop nivi-app-container || true
                        
                        # 3. Remove the old container container if it exists
                        docker rm nivi-app-container || true
                        
                        # 4. Run the new container from the updated image
                        # Note: Replace 80:80 with your app's actual port (e.g., 3000:3000, 8080:8080)
                        docker run -d --name nivi-app-container -p 80:80 nivi-image
                        
                        echo "Application successfully redeployed!"
EOF
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                echo "Verifying application status..."
                // Optional: add a health check curl command here
                // sh 'curl -f http://172.18.20.46:80'
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed. Check the logs above.'
        }
        always {
            // Cleans the workspace on the Jenkins master node
            cleanWs()
        }
    }
}