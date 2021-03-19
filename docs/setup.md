# Setup

## Containerized development 
For portability the repository comes with a `.devcontainer/devcontainer.json` file which describes that VSCode should use the `Dockerfile` to build and launch a docker container with all dependencies installed. 

This process uses the VSCode [remote development features](https://code.visualstudio.com/docs/remote/remote-overview), which need to be enabled. 
And of course docker needs to be installed. 

### Launch using docker-compose
If not using the *VSCode: Remote - Containers* extension there is a `docker-compose.yaml` describing how to launch the working environment using `docker-compose`:

1. run `docker-compose up -d` from the `.devcontainer/` folder
2. exec into the container by running `docker-compose exec devkube bash`

Do the development in the container. 

3. Afterwards, stop the development environmet by running `docker-compose down` 

### Launch using docker
It is also possible to launch the devleopment containe usind `docker`, 

 1. Build the image by running `docker build .` in the `.devcontainer/` folder
 2. run the container with the command: `docker run -d --mount source=<repository-folder>,target=/workspace/,type=bind <image> /bin/bash -c "while sleep 1000; do :; done"`
3. exec into the cotainer using `docker exec -it --user vscode --workdir /workspace <container> bash`

After development is done, stop the container using `docker stop <container>`. 



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
