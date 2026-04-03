pipeline {
    agent any
    environment {
        GIT_REPO = "https://github.com/ankitanallamilli/onlinebookstoreJava.git"
        GIT_BRANCH = "master"
        
        DOCKERHUB_USER = "ankitanallamilli"
        IMAGE_NAME = "javabook"
        IMAGE_TAG = "${BUILD_NUMBER}"
        DOCKER_CREDS = "Docker_CRED"
        
        NEXUS_URL = "http://100.28.125.79/:8081"
        GROUP_ID = "onlinebookstore"
        ARTIFACT_ID = "onlinebookstore"
        VERSION = "1.0.0"
        
        SONARQUBE_ENV = 'sq'
    }

      stages {
        stage('Checkout Code') {
            steps {
                checkout scmGit(
                    branches: [[name: "*/${GIT_BRANCH}"]],
                    userRemoteConfigs: [[
                        credentialsId: 'venkygit',
                        url: "${GIT_REPO}"
                    ]]
                )
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sq') {
                    sh 'mvn sonar:sonar'
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 2, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Build Artifact') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

         stage('upload artifact  to nexus') {
            steps {
             withMaven(globalMavenSettingsConfig: 'settings.xml', jdk: 'jdk21', maven: 'maven3', traceability: true) {
            sh 'mvn deploy'
     }
            }
        }
            stage('Download Artifact from Nexus') {
    steps {
        withCredentials([usernamePassword(credentialsId: 'nexus-creds', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
            sh "wget --user=$USER --password=$PASS -O ROOT.war ${NEXUS_URL}/repository/maven-releases/onlinebookstore/onlinebookstore/1.0.0/onlinebookstore-1.0.0.war"
        }
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
        stage('Deploy to Kubernetes') {
    steps {
        withKubeConfig([credentialsId: 'kubeconfig']) {

            sh """
            kubectl apply -f k8s/deployment.yml
            kubectl apply -f k8s/service.yml

            kubectl set image deployment/bookstore-deploy \
            bookstore-container=${DOCKERHUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}

            kubectl rollout status deployment/bookstore-deploy
            """
        }
    }
}
stage('Verif Deployment') {
    steps {
        withKubeConfig([credentialsId: 'kubeconfig']) {

            sh """
            kubectl get pods -o wide
            kubectl get svc
            """
        }
    }
}

        
    }
}
