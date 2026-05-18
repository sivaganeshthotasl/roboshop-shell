#!/bin/bash

AMI_ID="ami-0220d79f3f480ecf5"
SG_ID="sg-0f47a9bc6f43227ee"
HOSTED_ZONEID="Z02439601F28QTHNLZ5B8"
DOMAIN_NAME="robossl.shop"

# Instances list of Roboshop ("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "frontend")
EC2_INSTANCES=("redis" "user" "cart")

# Loop through all EC2 instances

for instance in "${EC2_INSTANCES[@]}"
do
    echo "Creating Roboshop EC2 Instance: $instance"

    # Create EC2 instance
    INSTANCE_ID=$(aws ec2 run-instances \
        --image-id "$AMI_ID" \
        --instance-type t3.micro \
        --security-group-ids "$SG_ID" \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
        --query "Instances[0].InstanceId" \
        --output text)

    echo "Created Instance ID: $INSTANCE_ID"

    # Wait until instance is running
    echo "Waiting for EC2 instance to start..."

    aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"

    # Get IP Address

    if [ "$instance" != "frontend" ]
    then
        IP=$(aws ec2 describe-instances \
            --instance-ids "$INSTANCE_ID" \
            --query "Reservations[0].Instances[0].PrivateIpAddress" \
            --output text)

        RECORD_NAME="$instance.$DOMAIN_NAME"

    else
        IP=$(aws ec2 describe-instances \
            --instance-ids "$INSTANCE_ID" \
            --query "Reservations[0].Instances[0].PublicIpAddress" \
            --output text)

        RECORD_NAME="$DOMAIN_NAME"
    fi

    echo "$instance IP Address: $IP"

    # Update Route53

    aws route53 change-resource-record-sets \
        --hosted-zone-id "$HOSTED_ZONEID" \
        --change-batch '{
            "Comment": "Creating or Updating DNS Record",
            "Changes": [{
                "Action": "UPSERT",
                "ResourceRecordSet": {
                    "Name": "'"$RECORD_NAME"'",
                    "Type": "A",
                    "TTL": 1,
                    "ResourceRecords": [{
                        "Value": "'"$IP"'"
                    }]
                }
            }]
        }'

    echo "Route53 record updated for $RECORD_NAME"
    echo "------------------------------------------"

done