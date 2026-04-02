pipeline {
    agent any

    environment {

        GIT_REPO = "https://github.com/ankitanallamilli/onlinebookstoreJava.git"
        GIT_BRANCH = "master"

        DOCKERHUB_USER = "ankitanallamilli"
        IMAGE_NAME = "ankitas-img"
        IMAGE_TAG = "${BUILD_NUMBER}"

        DOCKER_CREDS = "Docker_CRED"

        AWS_REGION = "us-east-1"
        EKS_CLUSTER = "saicluster"
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout scmGit(
                    branches: [[name: "*/${GIT_BRANCH}"]],
                    userRemoteConfigs: [[
                        credentialsId: 'GIT-Cred',
                        url: "${GIT_REPO}"
                    ]]
                )
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                docker build -t ${DOCKERHUB_USER}/${IMAGE_NAME}:${IMAGE_TAG} .
                """
            }
        }

        stage('DockerHub Login') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: "${DOCKER_CREDS}",
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh """
                    echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin
                    """
                }
            }
        }

        stage('Push Image to DockerHub') {
            steps {
                sh """
                docker push ${DOCKERHUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}
                """
            }
        }

        stage('Configure EKS Access') {
            steps {
                sh """
                aws eks --region ${AWS_REGION} update-kubeconfig --name ${EKS_CLUSTER}
                kubectl get nodes
                """
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh """
                kubectl apply -f k8s/deployment.yml
                kubectl apply -f k8s/service.yml

                kubectl set image deployment/bookstore-deploy \
                bookstore-container=${DOCKERHUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}

                kubectl rollout status deployment/bookstore-deploy
                """
            }
        }

        stage('Verify Deployment') {
            steps {
                sh """
                kubectl get pods -o wide
                kubectl get svc
                """
            }
        }
    }
}
