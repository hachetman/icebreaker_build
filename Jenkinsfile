pipeline {
    agent any

    stages {
        stage('Cmake') {
            steps {
                echo 'Cmake..'
                sh 'cmake .'
            }
        }
        stage('Build 7segment binary') {
            steps {
                sh 'make 7segment.bin'
            }
        }        
    }
}