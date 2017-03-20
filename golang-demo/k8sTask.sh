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

  echo "Removing existing deployment & service for the container."
  kubectl delete deployment --selector=name=$imageName
  kubectl delete svc --selector=name=$imageName
  
  echo "Building the image $imageName ($ENVIRONMENT)."
  docker build -f Dockerfile.debug -t $imageName:debug .
}

# Runs kubectl run.
kubectlRun () {
  echo "Starting kubectlRun"
  
  echo "Waiting for deletion..."
  waitForDeletion
  echo "Deletion complete"
    

  echo "Running kubectl run"
  kubectl run $imageName --image=$imageName:debug --port=2345 --image-pull-policy=IfNotPresent --labels=name=$imageName --expose

  echo "Waiting for pod to be ready"
  waitForPodReady
  echo "Exposing port 2345 as a NodePort service"
  podName=$(kubectl get pods -o custom-columns=NAME:.metadata.name --no-headers --selector=name=$imageName)  
  kubectl expose pod $podName --type=NodePort --overrides="{ \"spec\": { \"ports\": [{\"nodePort\": 32345, \"port\": 2345, \"targetPort\": 2345, \"protocol\": \"TCP\" }]}}"
}

waitForPodReady() {
  sleep 10
  
  # TODO fix the below. This currently returns pods that are created
  # but not yet ready, which won't allow port-forwarding.

  # n=0
  # until [ $n -ge 12 ]
  # do
  #   podName=$(kubectl get pods -o custom-columns=NAME:.metadata.name --no-headers --selector=name=$imageName)  

  #   if [[ -z $podName ]]; then
  #     sleep 5
  #     n=$[$n+1]
  #   else
  #     break;
  #   fi
  # done
}

waitForDeletion () {
  n=0
  until [ $n -ge 12 ]
  do
    podName=$(kubectl get pods -a -o custom-columns=NAME:.metadata.name --no-headers --selector=name=$imageName)  

    if [[ ! -z $podName ]]; then
      sleep 5
      n=$[$n+1]
    else
      break;
    fi
  done
}


# Shows the usage for the script.
showUsage () {
  echo "Usage: k8sTask.sh [COMMAND]"
  echo "    Runs build or run using debug environment"
  echo ""
  echo "Commands:"
  echo "    k8sRunForDebug: Builds the image and runs kubectl run."
  echo "    cleanAndBuild: Removes existing deployment of the image and rebuilds it."
  echo ""
  echo "Environments:"
  echo "    debug: Uses debug environment."
  echo ""
  echo "Example:"
  echo "    ./k8sTask.sh build"
  echo ""
  echo "    This will:"
  echo "        Build a Docker image named $imageName using debug environment."
}

eval $(minikube docker-env)

if [ $# -eq 0 ]; then
  showUsage
else
  case "$1" in
    "kubectlRunForDebug")
            buildApp
            cleanAndBuildImage
            kubectlRun
            ;;
    "cleanAndBuildImage")
            cleanAndBuildImage
            ;;
    *)
            showUsage
            ;;
  esac
fi