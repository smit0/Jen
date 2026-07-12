pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                // Clones the repository
                checkout scm
            }
        }

        stage('Copy Application') {
            steps {
                // Copies the Dockerfile and necessary files to the target server
                sh 'scp -i /var/lib/jenkins/.ssh/id_ed25519 -o StrictHostKeyChecking=no -r Dockerfile Jenkinsfile jenkinsfile_old opc@172.18.20.46:/home/opc/docker-app'
            }
        }

        stage('Deploy Docker') {
            steps {
                // Connects via SSH, changes directory to where the files are, and runs the build
                sh '''
                    ssh -i /var/lib/jenkins/.ssh/id_ed25519 -o StrictHostKeyChecking=no opc@172.18.20.46 << 'EOF'
                        cd /home/opc/docker-app
                        
                        echo "=================================="
                        echo "Building Docker Image..."
                        echo "=================================="
                        
                        # Dynamically tracks the image build using the context directory
                        docker build -t nivi-image .
EOF
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                echo "Verifying deployment..."
                // Add your deployment verification commands here (e.g., docker run or curl checks)
            }
        }
    }

    post {
        success {
            echo 'Deployment completed successfully!'
        }
        failure {
            echo 'Deployment failed.'
        }
        always {
            // Wipes the Jenkins workspace after the run to clean up build remnants
            cleanWs()
        }
    }
}