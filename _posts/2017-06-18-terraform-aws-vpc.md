---
layout:     post
title:      "Coding a VPC in Terraform"
subtitle:   "A terraform module for a VPC with Private Subnets"
date:       2017-06-18
authors:     [niek]
header-img: "img/piazza.jpg"
tags:       [aws, terraform]
comments: true
---

One of the common uses network setups in AWS is called [Scenario 2: VPC with Public and Private Subnets](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Scenario2.html). This is a that defines a Virtual Private Cloud (VPC), public subnets and private subnets. Setting up this infrastructure can be done via the AWS console or via cloud formation scripting. However, I prefer the tool [Terraform](https://www.terraform.io/) in which you can manage your infrastructure as code with a declarative language that supports building, changing and versioning your cloud in a modular way.

In this article I will describe how you can create a VPC with a public and private subnet on AWS using terraform. I will describe the setup step by step and I will show how to encapsulate all logic to one re-usable module.


> [Why we need subnets.](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Subnets.html) When you create a VPC, it spans all the Availability Zones in the region. After creating a VPC, you can add one or more subnets in each Availability Zone. When you create a subnet, you specify the CIDR block for the subnet, which is a subset of the VPC CIDR block. Each subnet must reside entirely within one Availability Zone and cannot span zones. Availability Zones are distinct locations that are engineered to be isolated from failures in other Availability Zones. By launching instances in separate Availability Zones, you can protect your applications from the failure of a single location.

Before you can start, you need an AWS account with sufficient rights (admin), and you should create a `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` to be able to access your account programmatically.

## Setting up your system.
The easiest way to use terraform is via docker. In that case you do not need any locally isntalled tools. We simply create a file called `.aws` where we put the AWS key and secret to athentication API calls, as shown below:

```
AWS_ACCESS_KEY_ID=<KEY>
AWS_SECRET_ACCESS_KEY=<SECRET>
```

## Creating a VPC part 1
All code for part 1 is available on [github](https://github.com/040code/blog_terraform-aws-vpc)

By default, terraform expects the configuration in a file called `main.tf`. Create the file and add the terraform provide for Amazon:

```
# main.tf
provider "aws" {
  region = "eu-west-1"
}
```
We are now ready to, step-by-step, add the terraform resources to create the VPC setup. First, have a look on the VPC setup as shown in the picture below.
<a href="#">
    <img src="{{ site.baseurl }}/img/nat-gateway-diagram.png" alt="nat-gateway-diagram">
</a>

We will start by creating the VPC itself: add the following snippet to your `main.tf`
```
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    label = "blog"
  }
}
```
Before we make the change effective we run a `terraform plan` to inspect the planned changes. You can install terraform locally or run the commands in a docker container. The docker command will export the AWS credentials to the container, mount the current directory to `/data` in the container, and set `/data` as working directory to ensure the container will execute the `terraform plan` command on the directory that contains the terraform files.
```
docker run -it --env-file ./.aws  -v $(pwd):/data -w /data \
  hashicorp/terraform:0.9.8 plan
```
After executing the plan command, you should see output similar to:
```
+ aws_vpc.vpc
    assign_generated_ipv6_cidr_block: "false"
    cidr_block:                       "10.0.0.0/16"
    default_network_acl_id:           "<computed>"
    default_route_table_id:           "<computed>"
    default_security_group_id:        "<computed>"
    dhcp_options_id:                  "<computed>"
    enable_classiclink:               "<computed>"
    enable_dns_hostnames:             "true"
    enable_dns_support:               "true"
    instance_tenancy:                 "<computed>"
    ipv6_association_id:              "<computed>"
    ipv6_cidr_block:                  "<computed>"
    main_route_table_id:              "<computed>"
    tags.%:                           "1"
    tags.label:                       "blog"


Plan: 1 to add, 0 to change, 0 to destroy.
```
This looks correct, so we can apply the change to create the VPC by running `terraform apply`.
```
docker run -it --env-file ./.aws  -v $(pwd):/data -w /data \
  hashicorp/terraform:0.9.8 apply
```

You can go VPC via the AWS console, where you should now see a VPC in the list named `blog`. Now we have the VPC, we create a public and private subnet by adding the following to the main.tf.
```
resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = false

  tags {
    Name = "blog"
  }
}

resource "aws_subnet" "private_subnet_a" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-1a"

  tags {
    Name = "blog"
  }
}
```
Run now `terraform plan` again, it will show that the resources will be added, one for each subnet. Apply the change using `terraform apply` and inspect your changes again via the VPC section in the AWS console.

Next, we connect the public subnet via an *internet gateway*. Create a routing table and an internet gateway. And a *aws_route_table_association* to create an association between a subnet and routing table. Update your `main.tf` with the snippet below, and run a plan and apply.

```
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_route_table" "public_routetable" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.internet_gateway.id}"
  }

  tags {
    label = "blog"
  }
}

resource "aws_route_table_association" "public_subnet_a" {
  subnet_id      = "${aws_subnet.public_subnet_a.id}"
  route_table_id = "${aws_route_table.public_routetable.id}"
}

```

We are now able to deploy an application to the public subnet and make it accessible via a security group. However, it is not yet possible to route traffic to the private subnet or let instances on the private subnet connect to internet. To do so, we add a NAT gateway and connect the gateway via a route table to the private subnet. The NAT gateway requires an elastic IP, which we will create first. Add the next terraform snippet to your `main.tf` and run a `plan` and `apply` to inspect and make the changes effective.

```
resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.public_subnet_a.id}"
}

resource "aws_route_table" "private_routetable" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat.id}"
  }

  tags {
    label = "blog"
  }
}

resource "aws_route_table_association" "private_subnet_a" {
  subnet_id      = "${aws_subnet.private_subnet_a.id}"
  route_table_id = "${aws_route_table.private_routetable.id}"
}
```

Setting up the VPC with subnets is quite verbose, and imagine then when you must support more availability zones, the code will almost double per zone. So we refactor it to a generic module to support the multiple subnets that are available in a zone.


## Creating a VPC part 2
I have rewritten the code showed above to a generic module. With this model, it is easy to create a VPC with all availability zones per zone, and private subnets can be enabled on demand.

> [Modules in terraform](https://www.terraform.io/docs/modules/usage.html) are self-contained packages of gerraform configurations that are managed as a group. Modules are used to create reusable components, improve organization, and to treat pieces of infrastructure as a black box.

I will not describe all code in the module again but only will pay attention to the significant changes I made. In the code above the zone, availability zone where hard coded. This will not work in a generic module. A common way to solve this in terraform is by creating a map where a zone is mapped to a list of availability zondes. By passing the zone to the moudle, the module can find out which availability zones there are. A default map is available in the module but can be ovewritten as follow:

```
availability_zones = {
  eu-west-1 = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}
```
The cdir block in the code show above was hard coded, but terraform contains a function to calculate the cdir block. In the module I use the terraform [function](https://www.terraform.io/docs/configuration/interpolation.html#cidrsubnet-iprange-newbits-netnum-) `cidrsubnet()` to calculate the cdir block.

Now only one problem needs to be solved in order to create a generic module: how can we create a AWS resource for each element in a list? Do we create subnet or route table association for each availability zone? Or how can we avoid creating a private subnet at all? The solution is to use the `count` variable in a module to iterate over the list of availability zones, which is available on my [github](https://github.com/npalm/tf-aws-vpc.git). We can now create a VPC similar to the one above with just a few line of code. Add the following lines to your terraform script to create a VPC.

```
module "vpc" {
  source = "git::https://github.com/npalm/tf-aws-vpc.git"

  key        = "blog"
  aws_region = "eu-west-1"
}
```
It is possible to overwrite module variables with default to get more control, see the ezample below:
```
module "vpc" {
  source = "git::https://github.com/npalm/tf-aws-vpc.git"

  key        = "blog"
  aws_region = "eu-west-1"

  create_private_hosted_zone = "false"
  create_private_subnets     = "false"
  cidr_block = "10.0.0.0/16"

  // example to override default availability_zones
  availability_zones = {
    eu-west-1 = ["eu-west-1a", "eu-west-1c"]
  }
}
```
