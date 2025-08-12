pipeline {
    agent { label 'gcp-node01' }

    environment {
        DOCKER_IMAGE = 'dancu25/test-site:latest'
    }

    stages {
        stage('Checkout Specific Branch') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: 'application']],
                    userRemoteConfigs: [[url: 'https://github.com/CuciureanuDan/gcp-infrastructure.git']]
                ])
            }
        }

         stage('Docker Login') {
             steps {
                 withCredentials([usernamePassword(credentialsId: 'docker-hub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                     sh 'echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin'
                 }
             }
         }

        stage('Build & Push Image') {
            steps {
                dir('nginx-site') {
                    sh 'chmod +x build.sh'
                    sh './build.sh'
                }
            }
        }

        stage('Deploy to Swarm') {
            steps {
                dir('nginx-site') {
                    sh 'chmod +x deploy.sh'
                    sh './deploy.sh'
                }
            }
        }
    }
}
