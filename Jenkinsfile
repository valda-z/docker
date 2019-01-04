pipeline {
  agent any
  stages {
    stage('test message') {
      steps {
        echo 'TEST'
      }
    }
    stage('build docker images') {
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
    stage('deploy') {
      steps {
        echo 'DONE!!'
        input(message: 'Deploy?', id: 'DEPLOY01', ok: 'Okay')
      }
    }
    stage('complete') {
      steps {
        echo 'COMPLETE!'
      }
    }
  }
}
