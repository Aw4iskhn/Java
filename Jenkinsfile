pipeline {
    agent any

tools {
        maven 'Maven 3.9.6' // Ensure this matches the Maven installation name in Jenkins
    }    
environment {
        // SonarQube Scanner configuration
        SONARQUBE_SCANNER_HOME = tool name: 'SonarQubeScanner', type: 'hudson.plugins.sonar.SonarRunnerInstallation'
        
        // Docker Hub credentials
        DOCKER_HUB_CREDENTIALS = credentials('docker-hub-credentials')
        
        // Application-specific variables
        APP_NAME = "java-app"
        DOCKER_IMAGE = "your-dockerhub-username/${APP_NAME}:${env.BUILD_ID}"
    }

    stages {
        // Stage 1: Checkout code from Git repository
        stage('Checkout') {
            steps {
                git branch: 'master', url: 'https://github.com/Aw4iskhn/Java.git'
            }
        }

        // Stage 2: Build the application using Maven
        stage('Build') {
            steps {
                sh 'mvn clean package'
            }
        }

        // Stage 3: Run unit tests
        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }

        // Stage 4: Perform SonarQube analysis
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh "${SONARQUBE_SCANNER_HOME}/bin/sonar-scanner -Dsonar.projectKey=java-app -Dsonar.sources=src -Dsonar.host.url=http://localhost:9000"
                }
            }
        }

        // Stage 5: Build Docker image
        stage('Build Docker Image') {
            steps {
                script {
                    docker.build(DOCKER_IMAGE, ".")
                }
            }
        }

        // Stage 6: Push Docker image to Docker Hub
        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'docker-hub-credentials') {
                        docker.image(DOCKER_IMAGE).push()
                    }
                }
            }
        }

        // Stage 7: Deploy to Docker container
        stage('Deploy') {
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'docker-hub-credentials') {
                        docker.image(DOCKER_IMAGE).run('-d -p 8080:8080 --name java-app-container')
                    }
                }
            }
        }

        // Stage 8: Monitor with Dynatrace and Grafana
        stage('Monitor') {
            steps {
                script {
                    // Install Dynatrace OneAgent (example for Linux)
                    sh 'curl -sSL https://your-dynatrace-server/api/v1/deployment/installer/agent/unix/default/latest?Api-Token=your-token -o dynatrace-installer.sh'
                    sh 'chmod +x dynatrace-installer.sh'
                    sh './dynatrace-installer.sh --set-app-log-content-access=true'

                    // Import Grafana dashboard (example using curl)
                    sh 'curl -X POST -H "Content-Type: application/json" -d @grafana-dashboard.json http://your-grafana-server:3000/api/dashboards/db'
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
