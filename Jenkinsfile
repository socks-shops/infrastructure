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

        stage('Install Velero') {
            agent {
                docker {
                    image 'socksshop/aws-cli-git-kubectl-helm:latest'
                    args '-u root -v $HOME/.kube:/root/.kube'
                }
            }
            steps {
                script {
                    withAWS(credentials: 'aws-credentials', region: "${AWS_REGION}") {
                        sh '''
                        aws eks --region $AWS_REGION update-kubeconfig --name $CLUSTER_NAME
                        chmod 600 /root/.kube/config
                        kubectl config current-context

                        helm repo add vmware-tanzu https://vmware-tanzu.github.io/helm-charts
                        helm repo update
                        helm upgrade --install velero vmware-tanzu/velero \
                            --namespace velero \
                            --create-namespace \
                            --set configuration.provider=aws \
                            --set configuration.backupStorageLocation.name=aws \
                            --set configuration.backupStorageLocation.bucket="velero-backups-bucket" \
                            --set configuration.backupStorageLocation.config.region="'$AWS_REGION'" \
                            --set configuration.volumeSnapshotLocation.name=aws \
                            --set configuration.volumeSnapshotLocation.config.region="'$AWS_REGION'" \
                            --set credentials.useSecret=false \
                            --set env.AWS_ACCESS_KEY_ID="'$AWS_ACCESS_KEY_ID'" \
                            --set env.AWS_SECRET_ACCESS_KEY="'$AWS_SECRET_ACCESS_KEY'"

                        kubectl get pods -n velero
                        '''
                    }
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
