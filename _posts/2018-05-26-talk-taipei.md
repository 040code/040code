---
layout:     post
title:      "Immutable Infrastructure"
subtitle:   "Cloud Native User Group Taipei"
date:       2018-05-26
authors:     [niek]
header-img: "img/strijp-s-ols.png"
tags:       [terraform, aws, docker, microservices]
---

The Docker slogan 'Build, Ship, and Run' advertises easy set up of immutable software builds, but it is not always that easy. Setting up immutable builds with Docker is pretty straight forward and shipping is just a matter of pushing the image to a repository. The next step is building the cloud infrastructure to run the containers. In the talk at
the Cloud Native Meetup in Taipei I have shown how to create an immutable infrastructure on AWS with Terraform. The example belows shows how you can run your micro services in docker containers on AWS.

In this talk I briefly touch upon building immutable software. But the main focus of the talk will be on creating an immutable infrastructure. In this talk I will show you how to create an immutable infrastructure on AWS with Terraform. I will use a real world example to explain and show live how easy you can get micro services live on AWS and continuously apply changes to the same cloud environment..

## Slides
Below the slides that I used for the talk, the slides are available as well on
[GitLab](https://immutable-infrastructure.gitlab.io/taipei-2018/). You can easy navigate through the slides with the spacebar.

<div style="position:relative; width:100%; height:0px; padding-bottom:56.25%;">
    <iframe style="position:absolute; left:0; top:0; width:100%; height:100%"
        src="https://immutable-infrastructure.gitlab.io/taipei-2018/">
    </iframe>
</div>

To get started with Terraform the best starting points are:
- [Terraform.io](https://www.terraform.io/intro/examples/)
- [Hello World example](https://github.com/npalm/tf-helloworld-demo)

## Examples

### Hello World
During the talk, I demonstrated a hello world example, see the link above. This examples shows some basics of terraform by creating a ec2 instance and security group to server a simple web application. The example only works in the AWS region `eu-west-1` since the AMI used is only available in this region.

### ECS demo
The second example I have shown, is creating an immutable infrastructure to server docker containers. The picture below descibes briefly the enviroment that will be cretaed.

<a href="#">
    <img src="{{ site.baseurl }}/img/20170919-immutable-infra/ecs-black.png" alt="ecs-diagram">
</a>

The example also creates log groups in cloudwatch to capture the logging of the ecs agent and the running containers (services).

#### Setup
Before you can start, you need an AWS account with sufficient rights (admin), and you should create a `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` to be able to access your account programmatically.

Clone the repository containing the ECS [sample](https://github.com/npalm/tf-ecs-demo.git) terraform code. To create the infrastructure step-by-step you can check out the tags `vpc` and `ecs`.

```
git clone https://github.com/npalm/tf-ecs-demo.git
git checkout taipei-vpc
```
You should also have Terraform installed (`home brew install terraform`) and
tfenv to manage your terraform installation. Alternatively use a docker container to run the terraform commands, for example:
```
docker run -it --env-file <AWS_KEYS_FILE> -v $(pwd):/data -w /data \
  hashicorp/terraform:0.10.4 <terraform command>
```
<br>

In this example you can swithc the reqion by changing the region variable
`aws_region` to your own choice. Or set the following environment variable: `export TF_VAR_aws_region=ap-northeast-1`
for Tokyo.

#### Create network layers (VPC)
In the next steps we will create the network layers.

First, we initialize and plan our changes.
```
terraform init
terraform plan
```
Terraform should print on the console that 19 needs to be added and 0 to change or destroyed. Next we apply the change be executing `terraform apply`.

#### Add ECS cluster
Now we have the network layer created, we will add the ECS cluster. By default the bastion host is disabled, the bastion can be enabled by updating the variable `enable_bastion` in the `terraform.tfvars` file. Time to plan and apply the new resources for ECS.
```
git checkout taipei-ecs-1
terraform plan
terraform apply
```
Once terraform is ready it will print the url of two applications on the console. One application, is a simple micro service that just prints the AWS availabilty zone where it is running, the other is a [graphql micro service](/2017/05/20/nextbuild-graphql/). It will take a few minutes before the services are available.

#### Adding your own service.
Time to have some more fun. Edit the `main.tf` and start making changes. Remove all the services, add your own service. By default for each service an application load balancer (ALB) is created. Add for each services that you want to deploy a configuration as below and update the variables as required.

```
module "your-service" {
  source = "ecs-service"

  service_name   = "<service-name>"
  image_url      = "<docker-image>"
  container_port = <port in the container where the service is listening>
  desired_count  = <number of instances>

  aws_region  = "${var.aws_region}"
  environment = "${var.environment}"

  vpc_id  = "${module.vpc.vpc_id}"
  subnets = "${module.vpc.public_subnets}"

  cluster_id            = "${module.ecs-cluster.cluster_id}"
  ecs_service_role_name = "${module.ecs-cluster.ecs_service_role_name}"
}
```
Now plan and apply your changes, Terraform will inform you that a few resources will be destroyed (the removed services) and a few will be added.


### Clean up
Once done you can easily clean-up all created resources in AWS, just run `terraform destroy`.

### Serverless containers.
Since a few months Amazon support running containers without managing your
ec2 instances, aka Serverless Containers. This services is called Fargate. I
have written a [blog
post](https://040code.github.io/2018/01/30/fargate_with_terraform/) about
how to run you containers serveless with terraform. Creating a mix of both
ways of running of containers is explained as well. Be aware that Fargate is
still only avaialable in `us-east-1`.

Have fun!