pipeline {

    agent any

    environment {
        TZ = "Asia/Kolkata"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {

                    def buildName = sh(
                        script: "TZ=Asia/Kolkata date +%d-%m-%Y-%H-%M-%S",
                        returnStdout: true
                    ).trim()

                    def imageName = "nivi-${buildName}"

                    echo "Building Image: ${imageName}"

                    docker.build(imageName)

                    env.IMAGE_NAME = imageName
                }
            }
        }

        stage('Deploy Container') {
            steps {
                script {

                    def containerName = "${env.IMAGE_NAME}-container"

                    echo "Deploying Container: ${containerName}"

                    sh """
                    docker run -d \
                        --restart unless-stopped \
                        --name ${containerName} \
                        ${env.IMAGE_NAME}
                    """
                }
            }
        }

        stage('Cleanup Old Containers') {
            steps {
                sh '''
                echo "Keeping latest 5 containers..."

                docker ps -a \
                --filter "name=nivi-" \
                --format "{{.CreatedAt}} {{.Names}}" | \
                sort -r | \
                awk '{print $NF}' | \
                tail -n +6 | \
                while read container
                do
                    echo "Removing $container"
                    docker rm -f $container
                done
                '''
            }
        }

        stage('Cleanup Old Images') {
            steps {
                sh '''
                echo "Keeping latest 5 images..."

                docker images \
                --format "{{.CreatedAt}} {{.Repository}}:{{.Tag}}" | \
                grep "^.* nivi-" | \
                sort -r | \
                awk '{print $NF}' | \
                tail -n +6 | \
                while read image
                do
                    echo "Removing image $image"
                    docker rmi -f $image || true
                done
                '''
            }
        }

        stage('Verify') {
            steps {
                sh '''
                echo "========== Docker Images =========="
                docker images

                echo
                echo "========== Running Containers =========="
                docker ps

                echo
                echo "========== All Containers =========="
                docker ps -a
                '''
            }
        }

    }

    post {

        success {
            echo "✅ Deployment Successful"
        }

        failure {
            echo "❌ Deployment Failed"
        }

    }

}