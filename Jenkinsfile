pipeline {
  agent any
  stages {
    stage('test') {
      steps {
        echo 'TEST'
      }
    }
    stage('error') {
      steps {
        sh 'docker images'
      }
    }
  }
}