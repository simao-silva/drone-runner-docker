# drone-runner-docker

![GitHub last commit](https://img.shields.io/github/last-commit/simao-silva/drone-runner-docker?style=for-the-badge)
![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/simao-silva/drone-runner-docker/docker-build-and-push.yml?style=for-the-badge)
[![GitHub license](https://img.shields.io/github/license/simao-silva/drone-runner-docker?style=for-the-badge)](https://github.com/simao-silva/drone-runner-docker/blob/main/LICENSE)

Multi-arch version of [runner-docker](https://github.com/drone-runners/drone-runner-docker) from drone-runners. 


## How to use it
Source: <https://docs.drone.io/runner/docker/installation/linux/>

### Standalone
```dockerfile
docker run --detach \
  --volume=/var/run/docker.sock:/var/run/docker.sock \
  --env=DRONE_RPC_PROTO=https \
  --env=DRONE_RPC_HOST=drone.company.com \
  --env=DRONE_RPC_SECRET=super-duper-secret \
  --env=DRONE_RUNNER_CAPACITY=2 \
  --env=DRONE_RUNNER_NAME=my-docker-runner \
  --publish=3000:3000 \
  --restart=always \
  --name=runner \
  simaofsilva/drone-runner-docker:latest
```

### Docker-compose

```yaml
drone-runner-docker:
    image: simaofsilva/drone-runner-docker:latest
    restart: unless-stopped
    environment:
        - DRONE_RPC_HOST=drone.company.com
        - DRONE_RPC_PROTO=https
        - DRONE_RPC_SECRET=super-duper-secret
    ports:
        - "3000:3000"
    volumes:
        - /var/run/docker.sock:/var/run/docker.sock
    depends_on:
        - drone
```
