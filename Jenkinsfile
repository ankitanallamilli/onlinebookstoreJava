pipeline {
    agent any

    environment {
        GIT_REPO = "https://github.com/ankitanallamilli/onlinebookstoreJava.git"
        GIT_BRANCH = "master"

        DOCKERHUB_USER = "ankitanallamilli"
        IMAGE_NAME = "javabook"
        IMAGE_TAG = "${BUILD_NUMBER}"
        DOCKER_CREDS = "Docker_CRED"

        NEXUS_URL = "http://100.28.125.79:8081"

        GROUP_ID = "onlinebookstore"
        ARTIFACT_ID = "onlinebookstore"
        VERSION = "1.0.0"

        SONARQUBE_ENV = "sq"
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


        stage('Build Artifact') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }


        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv("${SONARQUBE_ENV}") {
                    sh 'mvn sonar:sonar -Dsonar.java.binaries=target/classes'
                }
            }
        }


        stage('Quality Gate') {
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

