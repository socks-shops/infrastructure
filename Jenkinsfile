pipeline {
    agent {
        docker { image 'jenkins/jnlp-agent-terraform'}
    }
    environment {
        }
    stages {

        stage('Init') {
            steps {
                script {
                    sh """
                    terraform init
                    """
                }
            }
        }

        stage('Validate') {
            steps {
                script {
                    sh """
                    terraform validate
                    """
                }
            }
        }

        stage('Format') {
            steps {
                script {
                    sh """
                    terraform fmt
                    """
                }
            }
        }

        stage('Plan') {
            steps {
                script {
                    sh """
                    terraform plan
                    """
                }
            }
        }

        stage('Apply') {
            steps {
                withAWS(credentials: 'aws-credentials', region: "${AWS_REGION}") {
                    sh """
                    terraform apply --auto-approve
                    """
                }
            }
        }

        stage('Destroy') {
            steps {
                withAWS(credentials: 'aws-credentials', region: "${AWS_REGION}") {
                    input message: 'Lancer le destroy?', ok: 'Oui'
                    sh """
                    terraform destroy --auto-approve
                    """
                }
            }
        }

    }
}
