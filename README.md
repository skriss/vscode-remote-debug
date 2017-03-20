# vscode-remote-debug
This repo is a collection of simple demo applications demonstrating how to use VS Code to remote-debug into apps running in Kubernetes or plain Docker. 

Currently, examples exist for C#/.NET Core and golang. I plan to add another example for Node.js shortly.

## Motivations
As an engineer, I would like to retain the ease of debugging that I get from running code locally (fast build/deploy times, step-thru debugging, full control of environment) while also exercising the key components of my eventual production environment (containers, container orchestrator). This set of examples demonstrates how to integrate debuggers supporting remote execution (vsdbg for .NET Core, delve for golang) into the Docker/Kubernetes execution environment and VS Code IDE.

## A Quick Outline
The following are the key components of each solution:
- a debugger that supports remote execution (vsdbg for .NET Core, delve for golang)
- launch.json, which defines the launch configuration for your project (e.g. Run App in K8s - debug)
- tasks.json, which defines supporting tasks to enable the launch
- Dockerfile.debug, which defines the container to be built to enable debugging
- dockerTask.sh and k8sTask.sh, which implement the runtime-environment-specific behaviors to support push-button debugging 

## Limitations
This code should be considered proof-of-concept quality. I have made minimal effort to robustly handle errors, varying configurations, etc. Think of the samples as working guides to how to approach this problem rather than complete solutions.
