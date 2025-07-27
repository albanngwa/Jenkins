pipeline {
    agent any

    environment {
        REACT_APP_VERSION = "1.2.$BUILD_ID"
    }

    stages {
        stage('Deploy to AWS') {
            agent {
                docker {
                    image 'amazon/aws-cli'
                    reuseNode true
                    args "--entrypoint=''" 
                }
            }
            environment {
                // No additional env vars declared here (can be removed or used)
            }
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'AWS',
                    passwordVariable: 'AWS_SECRET_ACCESS_KEY',
                    usernameVariable: 'AWS_ACCESS_KEY_ID'
                )]) {
                    sh '''
                        aws --version
                        aws ecs register-task-definition --cli-input-json file://aws/task-definition-Prod.json
                    '''
                }
            }
        }

        stage('Build') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    ls -la
                    node --version
                    npm --version
                    npm ci
                    npm run build
                    ls -la
                '''
            }
        }
    }
}