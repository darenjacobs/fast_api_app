# Get Dockerhub token

# Change the following to your credentials

DOCKER_USERNAME=""
DOCKER_PASSWORD=""
DOCKER_IMAGE="fastapi-app"

TOKEN=$(curl -s -H "Content-Type: application/json" -X POST -d "{\"username\": \"$DOCKER_USERNAME\", \"password\": \"$DOCKER_PASSWORD\"}" https://hub.docker.com/v2/users/login/ | jq -r .token)


if [[ -d fastapi-app ]]; then
  cd fastapi-app
else
  echo "Docker applicaton not found"
fi


# build and push the Docker image
build() {
  echo "Getting Docker login Token"
  docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
  # echo ${TOKEN} | docker login -u $DOCKER_USERNAME --password-stdin

  if [[ "$OSTYPE" == "darwin"* ]]; then
    docker buildx create --name mybuilder --use
    docker buildx inspect --bootstrap
    docker buildx build --platform linux/amd64,linux/arm64 -t $DOCKER_USERNAME/$DOCKER_IMAGE:latest  .
    docker buildx build --platform linux/amd64,linux/arm64 -t $DOCKER_USERNAME/$DOCKER_IMAGE:latest . --push
    docker buildx rm mybuilder
  else
    docker build -t $DOCKER_USERNAME/$DOCKER_IMAGE:latest .
    docker push $DOCKER_USERNAME/$DOCKER_IMAGE:latest
  fi

  # Modify the terraform main.tf and ansible playbook.yml to use the new image name
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # MacOS uses sed -i '' for in-place substitution
    sed -i '' "s|sudo docker run -d -p 80:80 .*|sudo docker run -d -p 80:80 $DOCKER_USERNAME/$DOCKER_IMAGE:latest|" ../infra-automation/terraform/main.tf
    sed -i '' "s|docker_username:.*|docker_username: \"$DOCKER_USERNAME\"|" ../infra-automation/ansible/vars.yml
    sed -i '' "s|docker_image_name:.*|docker_image_name: \"$DOCKER_IMAGE:latest\"|" ../infra-automation/ansible/vars.yml
  else
    sed -i "s|sudo docker run -d -p 80:80 .*|sudo docker run -d -p 80:80 $DOCKER_USERNAME/$DOCKER_IMAGE:latest|" ../infra-automation/terraform/main.tf
    sed -i "s|docker_username:.*|docker_username: \"$DOCKER_USERNAME\"|" ../infra-automation/ansible/vars.yml
    sed -i "s|docker_image_name:.*|docker_image_name: \"$DOCKER_IMAGE:latest\"|" ../infra-automation/ansible/vars.yml
  fi

  echo "Updated main.tf with the new Docker image name."

}


# Delelet the docker image
delete() {
  # TESTING DELETE THE DOCKER IMAGE
  curl -s -X DELETE -H "Authorization: JWT $TOKEN" "https://hub.docker.com/v2/repositories/$DOCKER_USERNAME/$DOCKER_IMAGE/tags/latest/"
}

build

docker logout
