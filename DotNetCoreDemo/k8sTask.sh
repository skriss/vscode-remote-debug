#!/bin/sh

imageName="dotnetcoredemo"
projectName="dotnetcoredemo"
serviceName="dotnetcoredemo"
containerName="${projectName}_${serviceName}_1"
runtimeID="debian.8-x64"
framework="netcoreapp1.1"

# Kills existing deployment for the image
cleanAll () {
  if [[ -z $ENVIRONMENT ]]; then
    ENVIRONMENT="debug"
  fi

  kubectl delete deployment $imageName
}

# Builds the Docker image.
buildImage () {
  if [[ -z $ENVIRONMENT ]]; then
    ENVIRONMENT="debug"
  fi

  composeFileName="docker-compose.yml"
  if [[ $ENVIRONMENT != "release" ]]; then
    composeFileName="docker-compose.$ENVIRONMENT.yml"
  fi

  if [[ ! -f $composeFileName ]]; then
    echo "$ENVIRONMENT is not a valid parameter. File '$composeFileName' does not exist."
  else
    echo "Building the project ($ENVIRONMENT)."
    pubFolder="bin/$ENVIRONMENT/$framework/publish"
    dotnet publish -f $framework -r $runtimeID -c $ENVIRONMENT -o $pubFolder

    echo "Building the image $imageName ($ENVIRONMENT)."
    docker-compose -f "$pubFolder/$composeFileName" -p $projectName build
  fi
}

# Runs kubectl.
kubectlRun () {
    echo "Starting kubectlRun"
    
    deploymentName=$(kubectl get deployment -o custom-columns=NAME:.metadata.name --no-headers --selector=name=$imageName)  
    if [[ ! -z $deploymentName ]]; then
      echo "Running kubectl delete"
      kubectl delete deployment $imageName
      echo "Waiting for deletion..."
      waitForDeletion
      echo "Deletion complete"
    fi

    echo "Running kubectl run"
    kubectl run $imageName --image=$imageName:debug --image-pull-policy=IfNotPresent --labels=name=$imageName --env=REMOTE_DEBUGGING=1
    echo "Ran kubectl run"
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

startDebugging () {
  # wait for pod to be created/ready
  n=0
  until [ $n -ge 12 ]
  do
    podName=$(kubectl get pods -o custom-columns=NAME:.metadata.name --no-headers --selector=name=$imageName)  

    if [[ -z $podName ]]; then
      sleep 5
      n=$[$n+1]
    else
      break;
    fi
  done
  
  if [[ -z $podName ]]; then
    echo "Could not find a pod for deployment $imageName"
  else
    kubectl exec -i $podName -- /vsdbg/vsdbg --interpreter=vscode  
  fi
}

# Shows the usage for the script.
showUsage () {
  echo "Usage: k8sTask.sh [COMMAND]"
  echo "    Runs build or kubectl run using debug environment"
  echo ""
  echo "Commands:"
  echo "    build: Builds a Docker image ('$imageName')."
  echo "    clean: Removes the image '$imageName' and kills all containers based on that image."
  echo "    kubectlRunForDebug: Builds the image and runs kubectl run."
  echo "    startDebugging: Finds the running container and starts the debugger inside of it."
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
            buildImage
            kubectlRun
            ;;
    "startDebugging")
            startDebugging
            ;;
    "build")
            buildImage
            ;;
    "clean")
            cleanAll
            ;;
    *)
            showUsage
            ;;
  esac
fi