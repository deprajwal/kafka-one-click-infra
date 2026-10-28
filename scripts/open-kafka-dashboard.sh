
#!/bin/bash
set -euo pipefail

REGION="ap-south-1"
PROFILE="default"
LOCAL_PORT="8080"
REMOTE_PORT="8080"

INSTANCE_ID=$(aws --profile "$PROFILE" --region "$REGION" \
  ec2 describe-instances \
  --filters "Name=tag:Name,Values=kafka-one-click-server" \
            "Name=instance-state-name,Values=running" \
  --query 'Reservations[].Instances[].InstanceId | [0]' \
  --output text)

if [[ -z "$INSTANCE_ID" || "$INSTANCE_ID" == "None" ]]; then
  echo "ERROR: Running Kafka EC2 instance not found."
  exit 1
fi

echo "Kafka EC2: $INSTANCE_ID"
echo "Starting secure SSM tunnel..."
echo "Open Chrome: http://localhost:${LOCAL_PORT}"
echo "Keep this terminal open while using the dashboard."

exec aws --profile "$PROFILE" --region "$REGION" ssm start-session \
  --target "$INSTANCE_ID" \
  --document-name AWS-StartPortForwardingSession \
  --parameters "{\"portNumber\":[\"${REMOTE_PORT}\"],\"localPortNumber\":[\"${LOCAL_PORT}\"]}"
