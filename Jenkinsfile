pipeline {
    agent any

    stages {
        stage('Clone Repo') {
            steps {
                sh 'if stat jenkins-pipeline-lab;then rm -rf jenkins-pipeline-lab && git clone https://github.com/mikerkelly87/jenkins-pipeline-lab.git;fi'
            }
        }
        stage('Run pre-commit') {
            steps {
                sh 'cd jenkins-pipeline-lab; pre-commit run --all'
            }
        }
        stage('Pull container image') {
            steps {
                sh 'podman pull registry.access.redhat.com/ubi9/python-311'
            }
        }
        stage('Test the application in a container') {
            steps {
                sh 'cd jenkins-pipeline-lab; podman run -v ./:/opt/app-root/src/:Z --name app-test registry.access.redhat.com/ubi9/python-311 python3 py_ver_check.py'
            }
        }
    }
    post {
        always {
            sh 'if podman ps -a | grep app-test; then podman rm app-test; fi'
        }
    }
}
