---
layout:     post
title:      "Service Discovery on AWS"
subtitle:   "Enabling discovery for Spring Cloud on AWS ECS"
date:       2018-02-14
authors:     [niek]
header-img: "assets/2018-02-14-service-discovery/holstlaan-dommel.jpg"
tags: [aws, spring, docker]
---

Last year I wrote a [post](/2017/04/20/discovery-agent/) how to implement service discovery for Spring Boot applications running in Docker containers on AWS ECS. At that time the Amazon ECS agent does not have support to discover the docker exposed ports inside the container. In November 2017 Amazon released a feature in the [ECS agent 1.15](https://github.com/aws/amazon-ecs-agent/releases/tag/v1.15.0) to retrieve container meta data in the container. This feature makes the discovery agent obsolete.

### The problem
Looking back to the last years problem. A Spring service running in a container needs its external ip address and port to register to Eureka for service discovery. A service running in a container does not know the external exposed port and docker does not support a way to obtain the port mapping. We could inject the ip address but for the port that would not work. Since the port is unknown at start time. Of course, this in only valid when using random ports. But fixing the port can eventually cause port conflicts. Besides that, you are not able to scale the container on the same host. Therefore, it makes sense to use automatic port assignment.

At that time I have solved this problem by adding an agent that can be called via a REST interface to lookup the exposed port based on the container id and internal port. The agent returns the external port, and the service can use this information to register itself to Eureka. This approach worked well but since the ECS agent is now shipped with a feature to retrieve the meta data we do not need longer an extra agent anymore.

<a href="#">
    <img src="{{ site.baseurl }}/img/ecs1.png" height="80%" width="80%" alt="ECS">
</a>

### Solution
The approach to register the container to the discovery service remains the same. During container startup, the start script obtains the external ip address, and docker exposed port. The discovered information will be passed to the Spring Boot application using environment variables. At application start the Spring service discovery client uses the environment variables to register the application to Eureka.

<a href="#">
    <img src="{{ site.baseurl }}/assets/2018-02-14-service-discovery/sequence.png" height="100%" width="98%"  alt="Sequence Diagram">
</a>

Before we are able retrieve information about the container (in the container) we need to enable the feature on the ECS instance. For more details about this feature see the [Amazon documentation](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/container-metadata.html). To enable the meta data in the container you need to set `ECS_ENABLE_CONTAINER_METADATA` to `true`. This can be easily done by adding the line below the user data script.

```
echo ECS_ENABLE_CONTAINER_METADATA=true >> /etc/ecs/ecs.config
```

Now each created container by ECS on the EC2 instances will have the meta data available in the file assigned to the environment variable `ECS_CONTAINER_METADATA_FILE`. An example of the meta data looks like:

```
{
  "Cluster": "ecs-cluster",
  "ContainerInstanceARN": "arn:aws:ecs:eu-west-1:1234445678:some-id",
  "TaskARN": "arn:aws:ecs:eu-west-1:1234445678:some-other-id",
  "ContainerID": "container-id",
  "ContainerName": "my-service",
  "DockerContainerName": "docker-container-name",
  "ImageID": "image-id",
  "ImageName": "docker-image",
  "PortMappings": [
    {
      "ContainerPort": 8080,
      "HostPort": 320001,
      "BindIp": "0.0.0.0",
      "Protocol": "tcp"
    }
  ],
  "Networks": [
    {
      "NetworkMode": "default",
      "IPv4Addresses": [
        "172.17.0.2"
      ]
    }
  ],
  "MetadataFileStatus": "READY"
}
```

Next we fetch the ip address and port during container start. The ip address we still get through the standard amazon info endpoint.

```
export EUREKA_INSTANCE_IP_ADDRESS=$(curl --retry 5 --connect-timeout 3 -s 169.254.169.254/latest/meta-data/local-ipv4)
```

We extract the port mapping from the metadata using `jq`. We assume the service will run in the container on port 8080. Otherwise you can make this configurable as well.

```
export EUREKE_INSTANCE_NON_SECURE_PORT=$(cat ${ECS_CONTAINER_METADATA_FILE} | jq -c -r ".PortMappings[] | select(.ContainerPort == 8080) | .HostPort")
```
By using the Spring properties as environment variables, we can inject the information to the Spring application. Alternatively, you can use other names and assign the values in the `application.yml` file, see the example below.

```
eureka:
  instance:
    preferIpAddress: true
    ip-address: ${EXTERNAL_IP}
    non-secure-port: ${EXTERNAL_PORT}
```

With this approach the discovery agent becomes obsolete and we can retrieve the information for discovery through standard Amazon features.
