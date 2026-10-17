cd ~/Downloads/kafka-one-click-infra

cat > Jenkinsfile <<'EOF'
pipeline {
    agent any

    parameters {
        choice(
            name: 'ACTION',
            choices: ['CREATE', 'DESTROY'],
            description: 'CREATE Kafka infrastructure or DESTROY it to stop infrastructure charges'
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
        stage('Checkout and Check Tools') {
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

        stage('Initialize and Validate') {
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
                input message: 'Review the Terraform plan and AWS costs. Create Kafka infrastructure?',
                      ok: 'CREATE Infrastructure'
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

        stage('Configure Kafka') {
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

                    echo "Waiting for Kafka verification: $COMMAND_ID"

                    STATUS=""
                    for i in $(seq 1 60); do
                        STATUS=$(aws ssm get-command-invocation \
                          --region "$AWS_DEFAULT_REGION" \
                          --command-id "$COMMAND_ID" \
                          --instance-id "$KAFKA_INSTANCE_ID" \
                          --query 'Status' \
                          --output text 2>/dev/null || true)

                        case "$STATUS" in
                            Success)
                                echo "Kafka service is active."
                                aws ssm get-command-invocation \
                                  --region "$AWS_DEFAULT_REGION" \
                                  --command-id "$COMMAND_ID" \
                                  --instance-id "$KAFKA_INSTANCE_ID" \
                                  --query 'StandardOutputContent' \
                                  --output text
                                exit 0
                                ;;
                            Failed|Cancelled|TimedOut)
                                echo "Kafka verification failed: $STATUS"
                                aws ssm get-command-invocation \
                                  --region "$AWS_DEFAULT_REGION" \
                                  --command-id "$COMMAND_ID" \
                                  --instance-id "$KAFKA_INSTANCE_ID" \
                                  --query 'StandardErrorContent' \
                                  --output text || true
                                exit 1
                                ;;
                        esac

                        sleep 5
                    done

                    echo "Timed out waiting for Kafka verification. Last status: $STATUS"
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
                input message: 'This will destroy the Terraform-managed Kafka infrastructure. The Terraform state bucket will be preserved. Continue?',
                      ok: 'DESTROY Infrastructure'
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

                    # Empty only the SSM transfer bucket so Terraform can delete it.
                    # The separate Terraform state bucket is not touched.
                    aws s3 rm "s3://${SSM_BUCKET}" --recursive \
                      --region "$AWS_DEFAULT_REGION"

                    terraform -chdir=terraform apply -auto-approve terraform/tfplan
                '''
            }
        }
    }

    post {
        always {
            sh 'rm -f terraform/tfplan'
            echo 'Pipeline finished. Review the stage results.'
        }
    }
}
EOF