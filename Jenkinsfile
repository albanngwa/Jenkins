pipeline {
    agent any

    environment {
        NETLIFY_SITE_ID = '4c2a28cc-7eb9-4657-bfd4-828251cbfab8'
        NETLIFY_AUTH_TOKEN = credentials('netlify-token')
    }

    stages {
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

        stage('Tests') {
            parallel {
                stage('Test') {
                    agent {
                        docker {
                            image 'node:18-alpine'
                            reuseNode true 
                        }
                    }
                    steps {
                        sh '''
                            echo "Test Stage"
                            test -f build/index.html
                            npm test
                        '''
                    }
                    post {
                        always {
                            junit 'jest-results/junit.xml'
                        }
                    }
                }

                stage('E2E') {
                    agent {
                        docker {
                            image 'mcr.microsoft.com/playwright:v1.39.0-focal'
                            reuseNode true
                        }
                    }
                    steps {
                        sh '''
                            npm install serve
                            node_modules/.bin/serve -s build &
                            sleep 10
                            npx playwright test --reporter=html
                        '''
                    }
                    post {
                        always {
                            publishHTML([
                                allowMissing: false,
                                reportDir: 'playwright-report',
                                reportFiles: 'index.html',
                                reportName: 'playwright Local',
                                alwaysLinkToLastBuild: true,
                                keepAll: true
                            ])
                        }
                    }
                }
            }
        }

        stage('Deploy Staging') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    npm install netlify-cli@20.1.1 node-jq
                    node_modules/.bin/netlify deploy --dir=build --json > deploy-output.json
                '''
                script {
                    def url = sh(
                        script: "node_modules/.bin/node-jq -r '.deploy_url' deploy-output.json",
                        returnStdout: true
                    ).trim()
                    env.STAGING_URL = url
                    echo "Staging URL is: ${env.STAGING_URL}"
                }
            }
        }

        stage('Staging E2E') {
            agent {
                docker {
                    image 'mcr.microsoft.com/playwright:v1.39.0-focal'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    echo "Using staging URL: $STAGING_URL"
                    CI_ENVIRONMENT_URL=$STAGING_URL npx playwright test --reporter=html
                '''
            }
            post {
                always {
                    publishHTML([
                        allowMissing: false,
                        reportDir: 'playwright-report',
                        reportFiles: 'index.html',
                        reportName: 'Staging E2E',
                        alwaysLinkToLastBuild: true,
                        keepAll: true
                    ])
                }
            }
        }

        stage('Approval') {
            steps {
                timeout(time: 15, unit: 'MINUTES') {
                    input message: "Do you wish to Deploy to production?", ok: "Yes I am sure!"
                }
            }
        }

        stage('Deploy Prod') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true 
                }
            }
            environment {
                CI_ENVIRONMENT_URL = "https://dainty-llama-3e7693.netlify.app"
            }
            steps {
                sh '''
                    node --version
                    npm install netlify-cli@20.1.1
                    node_modules/.bin/netlify --version
                    echo "Deploying to production. Site ID: $NETLIFY_SITE_ID"
                    node_modules/.bin/netlify status
                    node_modules/.bin/netlify deploy --dir=build --prod
                    npx playwright test --reporter=html
                '''
            }
            post {
                always {
                    publishHTML([
                        allowMissing: false,
                        reportDir: 'playwright-report',
                        reportFiles: 'index.html',
                        reportName: 'Prod E2E',
                        alwaysLinkToLastBuild: true,
                        keepAll: true
                    ])
                }
            }
        }
    }
}
