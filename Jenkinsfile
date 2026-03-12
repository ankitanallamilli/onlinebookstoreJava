pipeline {
    agent any
    environment{
         IMAGE_NAME = "javabook"
         IMAGE_TAG = "v1"
         DOCKER_USER = "venkyveera"
    }
    stages {
        stage('get code from git') {
            steps {
               checkout scmGit(branches: [[name: '*/master']], extensions: [], userRemoteConfigs: [[credentialsId: 'venkygit', url: 'https://github.com/veeravenkateswararao/onlinebookstoreJava.git']])
            }
        }
         stage('validate') {
            steps {
               sh 'mvn validate'
            }
        }
       stage('compile') {
            steps {
               sh 'mvn compile'
            }
        }
           stage('test') {
            steps {
               sh 'mvn test'
            }
        }
       stage('package') {
            steps {
               sh 'mvn package'
            }
        }
        stage('docker build'){
           steps{
               sh 'docker build -t $DOCKER_USER/$IMAGE_NAME:$IMAGE_TAG .'
           }
        }
        stage('Docker Login'){
            steps{
                withCredentials([usernamePassword(
                    credentialsId: 'Docker_CRED',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                }
            }
        }
        stage('Docker push'){
            steps{
                 sh 'docker push $DOCKER_USER/$IMAGE_NAME:$IMAGE_TAG'
            }
        }
        stage('Docker deploy'){
            steps{
                sh '''
                docker stop bookstore || true
                docker rm bookstore || true
                docker run -d -p 8022:8080 --name bookstore $DOCKER_USER/$IMAGE_NAME:$IMAGE_TAG
                '''
            }
        }
      
    }
}
