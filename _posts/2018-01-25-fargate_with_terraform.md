---
layout:     post
title:      "Fargate with Terraform"
subtitle:   "Deploying serverless containers"
date:       2018-01-25
authors:     [niek]
header-img: "assets/2017-12-09_runners-on-the-spot/img/blob_glow.jpg"
tags:       [docker, aws, terraform]
enable_asciinema: 1
---

Last December at the AWS re:invent, AWS announced the new container service platform Fargate. Fargate is integrated to ECS. The key difference is that Fargate does not require you to have EC2 instances running to host your containers. A drawback is that Fargate is still not globally available, today Fargate is only available in `us-east-1`, see also the [list](https://aws.amazon.com/about-aws/global-infrastructure/regional-product-services/) of supported regions. Later in December Fargate also become available in terraform so time to see how it works.

In this post I will show you how to deploy containers to Fargate using Terraform. As example container I will use the is blog. The complete example in available on GitHub. For this example we will deploy the blog as container to Fargate in a private subnet and make it available via a load balancer to the public internet. We will also integrate CloudWatch for logging.

Prerequisites
Before you start you need to have programmatically access to an AWS account and Terraform (0.11+) installed. The tool [tfenv](http://brewformulas.org/Tfenv) let you manage multiple terraform version on your system.

Before we can create our containers, we have to create a few infrastructure components. First we create a VPC so we have an isolated network in our account.

```
provider "aws" {
  region  = "us-east-1"
  version = "1.7.1"
}

provider "template" {
  version = "1.0"
}

module "vpc" {
  source  = "npalm/vpc/aws"
  version = "1.1.0"

  environment = "blog"
  aws_region  = "us-east-1"

  // optional, defaults
  create_private_hosted_zone = "false"

  // example to override default availability_zones
  availability_zones = {
    us-east-1 = ["us-east-1a", "us-east-1b", "us-east-1c"]
  }
}

```


Next we create the ECS cluster as logical unit to deploy the containers and a CloudWatch log group so we can stream the container logging via awslogs.

```
resource "aws_ecs_cluster" "cluster" {
  name = "blog-ecs-cluster"
}

resource "aws_cloudwatch_log_group" "log_group" {
  name = "blog"
}
```
<asciinema-player src="{{ site.baseurl }}/assets/2018-01-25_fargate/asciinema/fargate-terraform-1.json"
  cols="166" rows="15" autoplay="true" loop="true" speed="1.5">
</asciinema-player>

The next step is to deploy our blog. In ECS you deploy a container via a task. And your container will be managed via a service. First we will create the task definition for our container. Fargate is using `awsvpc` as networking mode. This network mode requires a role for the task execution. In case you create your definition through the Amazon console a service linked role will be created for you. We will create this role also via code.
```
data "aws_iam_policy_document" "ecs_tasks_execution_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_tasks_execution_role" {
  name               = "blog-ecs-task-execution-role"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_tasks_execution_role.json}"
}

resource "aws_iam_role_policy_attachment" "ecs_tasks_execution_role" {
  role       = "${aws_iam_role.ecs_tasks_execution_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

```

Now we have the required role for task execution we will create the task definition. Which consists of two parts. First we define a container definition via a `template_file` next we define the task definition. To de ploy via Fargate we need to specify at least: requires_compatibilities, network_mode, cpu and memory.


```

data "template_file" "blog" {
  template = <<EOF
  [
    {
      "essential": true,
      "image": "npalm/040code.github.io:latest",
      "name": "blog",
      "portMappings": [
        {
          "hostPort": 80,
          "protocol": "tcp",
          "containerPort": 80
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "blog",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "040code"
        }
      }
    }
  ]

  EOF
}

resource "aws_ecs_task_definition" "task" {
  family                   = "blog-blog"
  container_definitions    = "${data.template_file.blog.rendered}"
  network_mode             = "awsvpc"        # required for Fargate
  cpu                      = "256"           # required for Fargate
  memory                   = "512"           # required for Fargate
  requires_compatibilities = ["FARGATE"]     # required for Fargate
  execution_role_arn       = "${aws_iam_role.ecs_tasks_execution_role.arn}"
}

```

<asciinema-player src="{{ site.baseurl }}/assets/2018-01-25_fargate/asciinema/fargate-terraform-2.json"
  cols="166" rows="15" autoplay="true" loop="true" speed="1.0">
</asciinema-player>

The next logical step in de AWS console would be to create the service and find out that the latest step that you need to create a load balancer before you can be finishing the service creation. So in code we will define the load balancer first. The load balancer will route traffic via HTTP to the container running in a private subnet.


```
resource "aws_security_group" "alb_sg" {
  name   = "blog-blog-alb-sg"
  vpc_id = "${module.vpc.vpc_id}"

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_alb" "main" {
  internal        = "false"
  subnets         = ["${module.vpc.public_subnets}"]
  security_groups = ["${aws_security_group.alb_sg.id}"]
}

resource "aws_alb_listener" "main" {
  load_balancer_arn = "${aws_alb.main.id}"
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.main.id}"
    type             = "forward"
  }
}

```
To the load balancer we connect a target group. For the target group we have to specify as target type `ip` and not `instance` since containers running in Fargate will get their own IP. Actually this not a Fargate but `awsvpc` behavior. The service that we create later will use the target group to register itself to the load balancer.

```

resource "aws_alb_target_group" "main" {
  port        = "80"
  protocol    = "HTTP"
  vpc_id      = "${module.vpc.vpc_id}"
  target_type = "ip"
}


output "blog_url" {
  value = "http://${aws_alb.main.dns_name}"
}

```
<asciinema-player src="{{ site.baseurl }}/assets/2018-01-25_fargate/asciinema/fargate-terraform-3.json"
  cols="166" rows="15" autoplay="true" loop="true" speed="1.5">
</asciinema-player>

We are almost there. Finally we have to create the service. A task running in in network ode `awsvpc` requires a service to define a network configuration which defines the allowed subnets and security groups to be applied. This means that we have to create another security group for our Fargate service.

```
resource "aws_security_group" "awsvpc_sg" {
  name   = "blog-awsvpc-cluster-sg"
  vpc_id = "${module.vpc.vpc_id}"

  ingress {
    protocol  = "tcp"
    from_port = 0
    to_port   = 65535

    cidr_blocks = [
      "${module.vpc.vpc_cidr}",
    ]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "blog-ecs-cluster-sg"
    Environment = "blog"
  }
}
```
The last resource to create is the service. In the service we connection the task, load balancer and security group together. By setting the launch type to `FARGATE` we tell amazon to deploy the container to Fargate.

```

resource "aws_ecs_service" "service" {
  name            = "blog"
  cluster         = "${aws_ecs_cluster.cluster.id}"
  task_definition = "${aws_ecs_task_definition.task.arn}"
  desired_count   = 1

  load_balancer = {
    target_group_arn = "${aws_alb_target_group.main.arn}"
    container_name   = "blog"
    container_port   = 80
  }

  launch_type = "FARGATE"

  network_configuration {
    security_groups = ["${aws_security_group.awsvpc_sg.id}"]
    subnets         = ["${module.vpc.private_subnets}"]
  }

  depends_on = ["aws_alb_listener.main"]
}
```

<asciinema-player src="{{ site.baseurl }}/assets/2018-01-25_fargate/asciinema/fargate-terraform-4.json"
  cols="166" rows="15" autoplay="true" loop="true" speed="1.5">
</asciinema-player>

That is all, we have now our blog running as serverless container in AWS Fargate.


<a href="#">
    <img src="{{ site.baseurl }}/assets/2018-01-25_fargate/img/ecs-fargate.png" alt="Fargate">
</a>
