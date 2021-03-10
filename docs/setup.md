# Setup

## Containerized development 
For portability the repository comes with a `.devcontainer/devcontainer.json` file which describes that VSCode should use the `Dockerfile` to build and launch a docker container with all dependencies installed. 

This process uses the VSCode [remote development features](https://code.visualstudio.com/docs/remote/remote-overview), which need to be enabled. 
And of course docker needs to be installed. 

## Remote development 
What seems to be the easiest way to have the build run on a remote machine, while having all the benefits of developing inside a container is to: 

- Configure a `docker context` with a remote docker endpoint as described [here](https://code.visualstudio.com/docs/containers/ssh) (Note that step 5. should be replaced by running the command `docker context use <name>` on the command line).

## Clone repository in container Volume 
It is advised to use the VSCode feature `Remote-Containers: Clone Repository in Container Volume` when first cloning the git repository. This creates a docker volume to contain the code. In the case of a remote docker context, this volume will also reside on the remote machine, and when developing locally on a Windows machine the volume lives inside `WSL` which improves input/output.

A single downside to this approach is that VSCode by default only clones the main branch. To remedy this simply change the fetch line in `.git/config` from
```
[remote "origin"] 
    fetch = +refs/heads/main:refs/remotes/origin/main
```
to
```
[remote "origin"]
    fetch = +refs/heads/*:refs/remotes/origin/*
```
[see](https://github.com/microsoft/vscode-remote-release/issues/4619) for more context.
