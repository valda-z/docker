pipeline {
  agent any
  stages {
    stage('test message') {
      steps {
        echo 'TEST'
      }
    }
    stage('build spa') {
      steps {
        sh 'docker build ./myappspa/Dockerfile'
      }
    }
    stage('done message') {
      steps {
        echo 'DONE!!'
      }
    }
  }
}