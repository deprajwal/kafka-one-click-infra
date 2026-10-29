
# Trust policy: allow EC2 instances to assume this role.
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    sid    = "AllowEC2AssumeRole"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# IAM role attached to the Kafka EC2 instance.
resource "aws_iam_role" "kafka_ec2_role" {
  name               = "kafka-one-click-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = {
    Name    = "kafka-one-click-ec2-role"
    Project = "kafka-one-click-infra"
  }
}

# Allow the EC2 instance to register with and communicate through SSM.
resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.kafka_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Allow the Kafka EC2 instance to download the Kafka archive
# from the dedicated SSM transfer bucket's kafka/ prefix.
data "aws_iam_policy_document" "kafka_s3_transfer" {
  statement {
    sid    = "DownloadKafkaArchive"
    effect = "Allow"

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.ssm_transfer.arn}/kafka/*"
    ]
  }
}

resource "aws_iam_role_policy" "kafka_s3_transfer" {
  name   = "kafka-one-click-s3-transfer"
  role   = aws_iam_role.kafka_ec2_role.id
  policy = data.aws_iam_policy_document.kafka_s3_transfer.json
}

# Instance profile used by the Kafka EC2 instance.
resource "aws_iam_instance_profile" "kafka_ec2_profile" {
  name = "kafka-one-click-instance-profile"
  role = aws_iam_role.kafka_ec2_role.name

  tags = {
    Project = "kafka-one-click-infra"
  }
}
