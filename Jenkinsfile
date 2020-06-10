pipeline {
    agent any

    stages {
        stage('Cmake') {
            steps {
                echo 'Cmake..'
                sh 'cmake .'
            }
        }
        stage('Build') {
            steps {
                echo 'Building 7segment binary'
                sh 'make 7segment.bin'
            }
        }        
    }
}