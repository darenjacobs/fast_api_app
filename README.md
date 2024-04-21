# Fastapi-App

## Directory Structure
```
/fastapi-app
├── app
│ └── main.py # FastAPI application code
├── Dockerfile # Docker configuration file
└── requirements.txt # Python dependencies

/infra-automation
├── terraform
│ ├── main.tf # Terraform configuration for AWS resources
│ ├── variables.tf # Terraform variable definitions
│ ├── outputs.tf # Terraform output configurations
│ └── modules
│ └── s3_backend
│ ├── bucket.tf # S3 bucket resource for Terraform backend
│ ├── dynamo.tf # DynamoDB table resource for Terraform locking
│ ├── main.tf # Main Terraform configuration for the s3_backend module
│ └── variables.tf # Variables for the s3_backend module
├── ansible
│ ├── ansible.cfg # Ansible configuration file
│ ├── vars.yml # Ansible variables file
│ └── playbook.yml # Ansible playbook for server configuration
└── README.md # Deployment instructions

```

## Prerequisites Applications:
AWS CLI
Terraform
ssh-keygen
jq

## Installation Instructions
### MacOS
```
brew install aws terraform jq
```
### Debian
```
apt install aws terraform jq
```

Note: at the time of this writing the latest version of terraform is 1.8.1.  Please use that version or higher

## Prerequisite Accounts
* AWS account with the access to create EC2 instance.
You'll need your
- Access key
- Secret access key

* Dockerhub (if you want to rebuild the Docker image)


## Customization Notes:
The Docker image has been built and uploaded to Docker Hub for your convenience. If you prefer to utilize a customized version of the fastapi-app, update the build_docker_image.sh script with your Docker Hub username and password, replacing the $DOCKER_USERNAME and $DOCKER_PASSWORD variables accordingly. Running this script will rebuild the Docker image, push it to your Docker Hub repository, and automatically update the main.tf and ansible vars.yml files to reference your custom image.


### Deployment
1. Clone the repository
2. cd fast_api_app
3. Execute the script script.sh
```
./script.sh
```

3. Open the browser and go to http://${AWS_PUBLIC_IP}/fibonacci/5


## Cleanup
```
destroy.sh
```
