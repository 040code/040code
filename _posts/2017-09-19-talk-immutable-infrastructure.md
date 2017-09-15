---
layout:     post
title:      "Immutable Infrastructure"
subtitle:   "Talk Devops Days Riga 2017"
date:       2017-09-15
authors:     [niek]
header-img: "img/strijp-s-olsopen .png"
tags:       [terraform, aws, docker]
---

A post to share the slides and examples I have used in my talk at the [DevOps Days Riga 2017](devopsdays.org/events/2017-riga/) on September the 19th.

## Slides
Below the slides that I used for the talk, the slides are available as well on [GitHub](https://npalm.github.io/immutable-infra-slides-20170919/). You can easy navigate through the slides with the spacebar.

<div style="position:relative; width:100%; height:0px; padding-bottom:56.25%;">
    <iframe style="position:absolute; left:0; top:0; width:100%; height:100%"
        src="https://npalm.github.io/immutable-infra-slides-20170919/">
    </iframe>
</div>

To get started with Terraform the best starting points are:
- [Terraform.io](https://www.terraform.io/intro/examples/)
- [Hello World example](https://github.com/npalm/tf-helloworld-demo)

## Examples

### Hello World
During the talk, I demonstrated a hello world example, see the link above. This examples shows some basics of terraform by creating a ec2 instance and security group to server a simple web application. The example only works in the AWS region `eu-west-1` since the AMI used is only available in this region.

### ECS demo
The second example I have shown is creating an immutable infrastucture to server docker containers.

<a href="#">
    <img src="{{ site.baseurl }}/img/20170919-immutable-infra/ecs-black.png" alt="ecs-diagram">
</a>


#### Setup
Before you can start, you need an AWS account with sufficient rights (admin), and you should create a `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` to be able to access your account programmatically.

Clone the repository containing the ECS [sample](https://github.com/npalm/tf-ecs-demo.git) terraform code. To create the infrastructure step-by-step you can checkout the tags `vpc` and `ecs`.

```
git clone https://github.com/npalm/tf-ecs-demo.git
git checkout vpc
```
You should also have Terraform installed (`home brew install terraform`) or use a docker container to run the terraform commands, for example:
```
docker run -it --env-file <AWS_KEYS_FILE>  -v $(pwd):/data -w /data \
  hashicorp/terraform:0.10.4 <terraform command>
```

#### Create network layers (VPC)
In the next steps we will create the network layers.

First we initialize and plan our changes.
```
terraform init
terraform plan
```
Terraform should print on the console that 19 needs to be added and 0 to change or destoyed. Next we apply the change be executing `terraform apply`.

#### Add ECS cluster
Now we have the network layer created, we will add the ECS cluster. By default the bastion host is disabled, the bastion can be enabled by updating the variable `enable_bastion` in the `terraform.tfvars` file. Time to plan and apply the new resources for ECS.
```
terraform plan
terraform apply
```
Once terraform is ready it will print the url of two applications on the console. One application is a simple services that just prints the AWS availabilty zone where it is running, the other is a [graphql micro service](/2017/05/20/nextbuild-graphql/). It will take a few minutes before the services are available.

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
Once done you can easily cleanup all created resources in AWS, just run `terraform destroy`.
