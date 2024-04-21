#!/bin/bash

# Remove pem key
KEY_NAME="mykey.pem"
if [[ -f ${KEY_NAME} ]]; then
  chmod 600 ${KEY_NAME}*
  rm ${KEY_NAME}*
fi


# Delete Instance first
if ! [[ -d infra-automation/terraform ]]; then
  echo "Terraform directory not found"
  exit 1
else
  cd infra-automation/terraform
fi

terraform destroy -var-file=terraform.tfvars -auto-approve
rm -rf .terraform*

cd ../../

# Delete s3_backened
if ! [[ -d infra-automation/terraform/modules/s3_backend ]]; then
  echo "Terraform directory not found"
  exit 1
else
  cd infra-automation/terraform/modules/s3_backend
fi

terraform destroy -auto-approve


if [[ -f terraform.tfstate ]]; then
  rm terraform.tfstate*
fi

if [[ -d .terraform ]]; then
  rm -rf .terraform*
fi

echo "DONT WORRY ABOUT THIS: 'Error: deleting S3 Bucket'"
echo "Or this: jq: error (at <stdin>:1):"


this_bucket="terraform-remote-state-pb0004888"
log_file="../../../../deletion_log.txt"

# Deleting object versions
echo "Deleting object versions..." >> "$log_file"
aws s3api list-object-versions --bucket "$this_bucket" \
--query 'Versions[].{Key:Key,VersionId:VersionId}' --output json | \
jq -c '.[]' | while read -r obj; do
    key=$(echo $obj | jq -r .Key)
    versionId=$(echo $obj | jq -r .VersionId)
    echo "Deleting $key with version $versionId" >> "$log_file"
    aws s3api delete-object --bucket "$this_bucket" --key "$key" --version-id "$versionId" >> "$log_file" 2>&1
done

# Deleting delete markers
echo "Deleting delete markers..." >> "$log_file"
aws s3api list-object-versions --bucket "$this_bucket" \
--query 'DeleteMarkers[].{Key:Key,VersionId:VersionId}' --output json | \
jq -c '.[]' | while read -r obj; do
    key=$(echo $obj | jq -r .Key)
    versionId=$(echo $obj | jq -r .VersionId)
    echo "Deleting delete marker for $key with version $versionId" >> "$log_file"
    aws s3api delete-object --bucket "$this_bucket" --key "$key" --version-id "$versionId" >> "$log_file" 2>&1
done

echo "Removing bucket..." >> "$log_file"
aws s3 rb s3://$this_bucket --force >> "$log_file" 2>&1
