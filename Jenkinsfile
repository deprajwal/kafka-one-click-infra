pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
        timeout(time: 60, unit: 'MINUTES')
    }

    environment {
        AWS_DEFAULT_REGION = 'ap-south-1'
        TF_DIR = 'terraform'
    }

    stages {
        stage('Checkout and Check Tools') {
            steps {
                sh '''
                    set -e
                    echo "Checking project tools..."
                    git --version
                    terraform version
                    ansible --version
                    aws --version
                    aws sts get-caller-identity
                '''
            }
        }

        stage('Validate Terraform') {
            steps {
                dir('terraform') {
                    sh '''
                        set -e
                        terraform init
                        terraform validate
                    '''
                }
            }
        }

        stage('Plan Infrastructure') {
            steps {
                dir('terraform') {
                    sh 'terraform plan -out=tfplan'
                }
            }
        }

        stage('Apply Infrastructure') {
            steps {
                input message: 'Proceed with AWS infrastructure creation? Review the Terraform plan and estimated costs first.',
                      ok: 'Apply Infrastructure'

                dir('terraform') {
                    sh 'terraform apply -auto-approve tfplan'
                }
            }
        }

        stage('Configure Kafka using Ansible') {
            steps {
                script {
                    env.KAFKA_INSTANCE_ID = sh(
                        script: 'terraform -chdir=terraform output -raw kafka_instance_id',
                        returnStdout: true
                    ).trim()

                    env.KAFKA_PRIVATE_IP = sh(
                        script: 'terraform -chdir=terraform output -raw kafka_private_ip',
                        returnStdout: true
                    )

                    env.SSM_BUCKET = sh(
                        script: 'terraform -chdir=terraform output -raw ssm_transfer_bucket',
                        returnStdout: true
                    ).trim()
                }

                sh '''
                    set -e

                    ansible-galaxy collection install amazon.aws

                    cat > ansible/inventory.ini <<INVENTORY
[kafka]
${KAFKA_INSTANCE_ID}

[kafka:vars]
ansible_connection=amazon.aws.aws_ssm
ansible_aws_ssm_region=${AWS_DEFAULT_REGION}
ansible_aws_ssm_bucket_name=${SSM_BUCKET}
ansible_aws_ssm_bucket_sse_mode=AES256
ansible_user=ec2-user
INVENTORY

                    ansible-playbook \
                      -i ansible/inventory.ini \
                      ansible/site.yml \
                      -e "kafka_advertised_host=${KAFKA_PRIVATE_IP}"
                '''
            }
        }

        stage('Verify Kafka') {
            steps {
                sh '''
                    set -e
                    aws ssm send-command \
                      --region "$AWS_DEFAULT_REGION" \
                      --instance-ids "$KAFKA_INSTANCE_ID" \
                      --document-name "AWS-RunShellScript" \
                      --parameters '{"commands":["sudo systemctl is-active kafka"]}' \
                      --query 'Command.CommandId' \
                      --output text
                '''
            }
        }
    }

    post {
        always {
            sh 'rm -f terraform/tfplan'
            echo 'Pipeline finished. Review each stage for its result.'
        }
    }
}