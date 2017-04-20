---
layout:     post
title:      "Dicover the exposed port"
subtitle:   "Enabling discovery for Spring Cloud on AWS ECS"
date:       2017-04-20 14:22:00
author:     "Niek Palm"
header-img: "img/silly-walk-this-way-dommeltunnel.png"
tags: [docker, aws, spring]
---

This post describes a solution how to implement discovery of the random exposed port by a [Docker](https://www.docker.com/) container. A specific situation where the problem occurs is once you deploy [Spring Cloud](http://projects.spring.io/spring-cloud/) micro services as [Amazon ECS](https://aws.amazon.com/ecs/) services to the cloud.

### The problem
Settings up a micro services architecture requires that there is a way services can find each other. Spring Cloud provides a services discovery services out of the box, Eureka. Services running in the micro services landscape are responsible to register themselves to the discovery services. Other services can obtain via the discovery service base on the name the location where a service is running. Deploying those services to a docker based cloud such as AWS creates some difficulties.

A service that is running in a container does not know the external exposed port. The port map can be fixed for example mapping the external port on the same port as the internal one but this will create sooner or later port conflicts. Besides that, you are not able to scale the container on the same host, port conflict. So it is quite logical to choose for automatic port assignment. But in that case, there is a need that the services can discover the by docker mapped port for registration.

Running micro services in docker containers on AWS ECS looks as follow.

<a href="#">
    <img src="{{ site.baseurl }}/img/ecs1.png" height="80%" width="80%" alt="ECS">
</a>

Each micro service is defined as task which will run as service (a docker container). The docker containers runs on a Amazon EC2 instance where also a docker agent is running to manage the cluster. Unfortunately, the agent has no API to lookup the exposed port.

### Solution
To lookup the expose port an extra agent is added to the EC2 instance. The [discovery agent](https://github.com/npalm/docker-discovery-agent) has the capability via an API to discover the port for a given container id, an internal port and protocol. The only drawback is that the discovery agent needs to have access to the docker socket which is a potential security risk.

<a href="#">
    <img src="{{ site.baseurl }}/img/ecs2.png" height="100%" width="100%" alt="ECS">
</a>

Let’s explain the working of the discovery agent by example: Frist we have to start the agent as a docker container.

```
docker run -d -v /var/run/docker.sock:/var/run/docker.sock \
  --name docker-discovery-agent -p 5555:8080 npalm/docker-discovery-agent:1.0.0
```
Now the agent is running it is time to test it. For testing we start another container, remember the problem is that we need to be able to lookup the exposed port **in** a container. The local ip address will be added as extra host to the container. The test container is just a linux container containing the tool `curl`. Port 80 is exposed to a random port.

```
export DOCKERHOST=$(ifconfig | grep -E "([0-9]{1,3}\.){3}[0-9]{1,3}" | \
  grep -v 127.0.0.1 | awk '{ print $2 }' | cut -f2 -d: | head -n1)
docker run -it -p 80 --add-host="dockerhost:$(DOCKERHOST)" --rm centos /bin/bash
```
We are now in the shell of the centos container, the host file contains a DNS entry that points to the host. First, we have the search for the id of the current container.

```
CONTAINER_ID=$(cat /proc/self/cgroup | grep "cpu:/" | sed 's/\([0-9]\):cpu:\/docker\///g')
```
Finally, we ask the discovery agent for our external mapped port be sending the container id and the internal port.
```
curl "http://dockerhost:5555/container/${CONTAINER_ID}/portbinding?port=80&protocol=tcp"
```
The result is a JSON string container the hostIp and hostPort, for example:
```
{
	"HostIp": "0.0.0.0",
	"HostPort": "32779"
}
```
As alternative of passing the host ip address it is possible to register a static ip address and use this to find the dicovery agent.
```
sudo ifconfig lo0 alias 172.16.123.1
```

Okay now we have a way to discover the exposed let’s give some direction how this could be combined with Spring Cloud on ECS. First deploy Eureka (service discover) as container. Register an ALB (internal) to the service. Now we have an endpoint that we can use to inject the services that needs to register itself. Next create a spring service that is aware of discovery. Before the services can started, the exposed port needs to be found. Add the snippet below to the start script to start the services in the container.

```
#!/bin/bash
export DOCKER_HOST=$(curl -s 169.254.169.254/latest/meta-data/local-ipv4)
export CONTAINER_ID=$(cat /proc/self/cgroup | grep "cpu:/" | \
  sed 's/\([0-9]\):cpu:\/docker\///g')
export NETWORK_BINDING=\
  $(curl "http://${DOCKER_HOST}:5555/container/${CONTAINER_ID}/portbinding?port=8080&protocol=tcp")
export EXPOSED_PORT=$(echo ${NETWORK_BINDING} | jq -c '.[0].HostPort' | \
  sed -e 's/^"//'  -e 's/"$//')

exec java -jar /service.jar
```
The last step is to update the `application.yml` and add a few lines to force the ip address and port during service registration.

```
eureka:
  client:
    serviceUrl:
      defaultZone: ${EUREKA_URL} // Needs to be injected as environment variable
  instance:
    preferIpAddress: true
    ip-address: ${DOCKER_HOST}
    non-secure-port: ${EXPOSED_PORT}
```

### Alternatives
There are many alternatives and many discussion about this topic, please see also [docker issue](https://github.com/docker/docker/issues/3778). This issue a good starting point for alternatives. The following alternatives came to my mind:
- Same approach but not as container but as agent direct on the host.
- Implement the discovery capability in each servie as a library, but the drawback is that all the services needs the docker socket.
- Choose another discovery mechanism for example based on ALB.
- Switch to [Consul](https://github.com/hashicorp/consul) in combination with a [registrator](https://github.com/gliderlabs/registrator)
