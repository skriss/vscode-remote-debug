imageName="golang-demo"
containerName="${imageName}"

buildApp () {
  echo "running go build"
  go build
}

# Builds the Docker image.
cleanAndBuildImage () {
  if [[ -z $ENVIRONMENT ]]; then
    ENVIRONMENT="debug"
  fi

  echo "Removing the current image and any associated containers."
  docker rmi -f $imageName
  docker stop $containerName
  docker rm $containerName
  
  echo "Building the image $imageName ($ENVIRONMENT)."
  docker build -f Dockerfile.debug -t $imageName .
}

# Runs docker-compose.
dockerRun () {
  if [[ -z $ENVIRONMENT ]]; then
    ENVIRONMENT="debug"
  fi

  echo "Running image $imageName"
  docker run -d --name $imageName --privileged -p 2345:2345 $containerName
}

# Shows the usage for the script.
showUsage () {
  echo "Usage: dockerTask.sh [COMMAND]"
  echo "    Runs build or run using debug environment"
  echo ""
  echo "Commands:"
  echo "    dockerRunForDebug: Builds the image and runs docker run."
  echo "    cleanAndBuild: Removes existing instance of the image and rebuilds it."
  echo ""
  echo "Environments:"
  echo "    debug: Uses debug environment."
  echo ""
  echo "Example:"
  echo "    ./dockerTask.sh build"
  echo ""
  echo "    This will:"
  echo "        Build a Docker image named $imageName using debug environment."
}

if [ $# -eq 0 ]; then
  showUsage
else
  case "$1" in
    "dockerRunForDebug")
            buildApp
            cleanAndBuildImage
            dockerRun
            ;;
    "cleanAndBuildImage")
            cleanAndBuildImage
            ;;
    *)
            showUsage
            ;;
  esac
fi