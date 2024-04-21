#!/bin/bash
# Set region
echo "Please specify a region"
region="us-east-1"
export AWS_REGION="${region}"
export AWS_DEFAULT_REGION="${regtion}"

# AWS Configure
aws configure

if ! [[ -d infra-automation/terraform/modules/s3_backend ]]; then
  echo "Terraform directory not found"
  exit 1
else
  cd infra-automation/terraform/modules/s3_backend
fi

terraform init
terraform plan
terraform apply -auto-approve

sleep 5

cd ../../../../  # to fast_api_app

KEY_NAME="mykey.pem"


# Create SSH keypair
if [[ -f ${KEY_NAME} ]]; then
  chmod 600 ${KEY_NAME}*
  rm ${KEY_NAME}*
fi
#ssh-keygen -t rsa -b 4096 -f mykey -N ""
ssh-keygen -m PEM -t rsa -b 4096 -f $KEY_NAME -N ""
chmod 400 ${KEY_NAME}*


# Check for keypair
check_keypair=$(aws ec2 describe-key-pairs --key-names "$KEY_NAME" --region $region --query 'KeyPairs[].KeyName' --output text)

# Delete the keypair if it exists
if [[ $check_keypair == "$KEY_NAME" ]]; then
  aws ec2 delete-key-pair --key-name "$KEY_NAME" --region $region
fi

# Install the keypair in your region
aws ec2 import-key-pair --key-name "$KEY_NAME" --public-key-material fileb://$KEY_NAME.pub --region $region


# Get Free Ubuntu 22.04 LTS AMI
ami_id=$(aws ec2 describe-images \
  --region $region \
  --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20240301*" \
  --query "Images | sort_by(@, &CreationDate) | [0].ImageId" \
  --output text)


# Check if AMI ID was fetched successfully
if [ -z "$ami_id" ]; then
  echo "Failed to fetch AMI ID"
  exit 1
else
  echo "Fetched AMI ID: $ami_id"
fi

#update the variables.tf file
variables="infra-automation/terraform/variables.tf"

# Check the operating system and use appropriate sed syntax
if [[ "$OSTYPE" == "darwin"* ]]; then
    # MacOS uses sed -i '' for in-place substitution
    sed -i '' "s/default = \"ami-id\"/default = \"$ami_id\"/" $variables
else
    # Linux uses sed -i for in-place substitution
    sed -i "s/default = \"ami-id\"/default = \"$ami_id\"/" $variables
fi

echo "Updated variables.tf with the new AMI ID."


maintf="infra-automation/terraform/main.tf"
# update backend section in main.tf file
if [[ "$OSTYPE" == "darwin"* ]]; then
  # MacOS uses sed -i '' for in-place substitution
  sed -i '' "s/region *= *\"us[-a-zA-Z0-9]*\"/region         = \"$region\"/g" $maintf
else
  sed -i "s/region *= *\"us[-a-zA-Z0-9]*\"/region         = \"$region\"/g" $maintf
fi


# Create TFvars
tfvars="infra-automation/terraform/terraform.tfvars"

# remove tfvars if it exists
if [[ -f $tfvars  ]]; then
  rm $tfvars
fi

# Create terraform.tfvars
cat << EOF > $tfvars
# terraform.tfvars

# The AMI ID for the Ubuntu Server 22.04 LTS you want to use
# This AMI ID is region-specific and is an example; please replace it with a valid one for your AWS region.
server_ami = "${ami_id}"

key_name = "${KEY_NAME}"
EOF




# Use Terraform to build the Instance

if ! [[ -d infra-automation/terraform ]]; then
  echo "Terraform directory not found"
  exit 1
else
  cd infra-automation/terraform
fi

terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars -auto-approve




sleep 20

# display URL
# The input string
input=$(terraform output)

# Extract the IP address using `cut` and `tr` to remove the quotes
ip=$(echo $input | cut -d '"' -f 2 | tr -d '"')

# Construct the URL with the extracted IP address
echo "http://${ip}/fibonacci/5"

echo "Wait approximately 1 minute"


# Set variables.tf back to default = "ami-id"
cd ../../
git checkout -- infra-automation/terraform/variables.tf




# If using ansible instead of terraform, comment main.tf user_data, add ingress for "SSH" from & to port 22 tcp on YOUR IP address.
# ansible-playbook -i $(terraform output -raw instance_public_ip), playbook.yml
