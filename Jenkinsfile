pipeline {
    agent any

    parameters {
        choice(
            name: 'ACTION',
            choices: ['CREATE', 'DESTROY'],
            description: 'Create or destroy Kafka infrastructure'
        )
    }

    options {
        timestamps()
        disableConcurrentBuilds()
        timeout(time: 60, unit: 'MINUTES')
    }

    environment {
        PATH = "/opt/homebrew/bin:/opt/homebrew/sbin:/usr/bin:/bin:/usr/sbin:/sbin"
        AWS_DEFAULT_REGION = 'ap-south-1'
        AWS_PROFILE = 'default'
        ANSIBLE_CONFIG = "${WORKSPACE}/ansible.cfg"
    }

    stages {
        stage('Check Tools and AWS') {
            steps {
                sh '''
                    set -e
                    git --version
                    terraform version
                    ansible --version
                    aws --version
                    aws sts get-caller-identity
                '''
            }
        }

        stage('Terraform Init and Validate') {
            steps {
                dir('terraform') {
                    sh '''
                        set -e
                        terraform init -reconfigure
                        terraform validate
                    '''
                }
            }
        }

        stage('Plan CREATE') {
            when {
                expression { params.ACTION == 'CREATE' }
            }
            steps {
                dir('terraform') {
                    sh 'terraform plan -out=tfplan'
                }
            }
        }

        stage('Approve CREATE') {
            when {
                expression { params.ACTION == 'CREATE' }
            }
            steps {
                input message: 'Review the Terraform plan and AWS costs before creating resources.',
                      ok: 'Approve CREATE'
            }
        }

        stage('Apply CREATE') {
            when {
                expression { params.ACTION == 'CREATE' }
            }
            steps {
                dir('terraform') {
                    sh 'terraform apply -auto-approve tfplan'
                }
            }
        }

        stage('Configure Kafka with Ansible') {
            when {
                expression { params.ACTION == 'CREATE' }
            }
            steps {
                script {
                    env.KAFKA_INSTANCE_ID = sh(
                        script: 'terraform -chdir=terraform output -raw kafka_instance_id',
                        returnStdout: true
                    ).trim()

                    env.KAFKA_PRIVATE_IP = sh(
                        script: 'terraform -chdir=terraform output -raw kafka_private_ip',
                        returnStdout: true
                    ).trim()

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
            when {
                expression { params.ACTION == 'CREATE' }
            }
            steps {
                script {
                    env.KAFKA_INSTANCE_ID = sh(
                        script: 'terraform -chdir=terraform output -raw kafka_instance_id',
                        returnStdout: true
                    ).trim()
                }

                sh '''
                    set -e
                    COMMAND_ID=$(aws ssm send-command \
                      --region "$AWS_DEFAULT_REGION" \
                      --instance-ids "$KAFKA_INSTANCE_ID" \
                      --document-name "AWS-RunShellScript" \
                      --parameters '{"commands":["sudo systemctl is-active kafka"]}' \
                      --query 'Command.CommandId' \
                      --output text)

                    for i in $(seq 1 60); do
                        STATUS=$(aws ssm get-command-invocation \
                          --region "$AWS_DEFAULT_REGION" \
                          --command-id "$COMMAND_ID" \
                          --instance-id "$KAFKA_INSTANCE_ID" \
                          --query 'Status' --output text 2>/dev/null || true)

                        if [ "$STATUS" = "Success" ]; then
                            echo "Kafka is active."
                            exit 0
                        fi

                        case "$STATUS" in
                            Failed|Cancelled|TimedOut)
                                echo "Kafka verification failed: $STATUS"
                                exit 1
                                ;;
                        esac
                        sleep 5
                    done

                    echo "Kafka verification timed out."
                    exit 1
                '''
            }
        }

        stage('Plan DESTROY') {
            when {
                expression { params.ACTION == 'DESTROY' }
            }
            steps {
                dir('terraform') {
                    sh 'terraform plan -destroy -out=tfplan'
                }
            }
        }

        stage('Approve DESTROY') {
            when {
                expression { params.ACTION == 'DESTROY' }
            }
            steps {
                input message: 'This removes Terraform-managed infrastructure. Preserve the separate Terraform state bucket.',
                      ok: 'Approve DESTROY'
            }
        }

        stage('Apply DESTROY') {
            when {
                expression { params.ACTION == 'DESTROY' }
            }
            steps {
                script {
                    env.SSM_BUCKET = sh(
                        script: 'terraform -chdir=terraform output -raw ssm_transfer_bucket',
                        returnStdout: true
                    ).trim()
                }

                sh '''
                    set -e
                    aws s3 rm "s3://${SSM_BUCKET}" \
                      --recursive --region "$AWS_DEFAULT_REGION"
                    terraform -chdir=terraform apply -auto-approve terraform/tfplan
                '''
            }
        }
    }

    post {
        always {
            sh 'rm -f terraform/tfplan'
            echo 'Pipeline finished. Check the stage results.'
        }
    }
}
