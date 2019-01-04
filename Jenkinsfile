pipeline {
  agent any
  stages {
    stage('test message') {
      steps {
        echo 'TEST'
      }
    }
    stage('build spa') {
      parallel {
        stage('build spa') {
          steps {
            sh 'docker build ./myappspa'
          }
        }
        stage('build todo') {
          steps {
            sh 'docker build ./myapptodo'
          }
        }
      }
    }
    stage('done message') {
      steps {
        echo 'DONE!!'
      }
    }
  }
}