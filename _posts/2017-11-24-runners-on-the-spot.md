---
layout:     post
title:      "Runners on the Spot"
subtitle:   "Auto scaling GitLab runners on AWS"
date:       2017-11-24
authors:     [niek]
header-img: "assets/2017-12-05_runners-on-the-spot/img/blob_glow.jpg"
tags:       [gitlab, docker, aws, terraform]
enable_asciinema: 1
---

## Introduction

[GitLab CI](https://about.gitlab.com/features/gitlab-ci-cd/) is a first class citinzen in GitLab to enable continuous integration and delivery to your project. Builds are orchestrated via the [GitLab Runners](https://docs.gitlab.com/runner/) which is an agent registred to your GitLab. The agent can run jobs (builds) via docker containers or local shell execution. Looking for a place to hosts the build we came across to run them on AWS using spot instances and auto-scaling. So we can keep the costs low by using the cheap spot instances, and only scale in case a build is requested.

On the GitLab blog the article: [Autoscale  GitLab CI runners and save 90% on EC2 costs,](https://about.gitlab.com/2017/11/23/autoscale-ci-runners/) explains how to setup the runners on AWS. But the setup is al lot of manual work, besides setting up infrastructure manually is error-prone. It is also a bad practice which we can avoid easily using tools like CloudFormation or Terraform. This artical explain show you can set up GitLab Runners ons AWS spot instances with [Hashicorp Terraform](https://www.terraform.io/).

<a href="#">
    <img src="{{ site.baseurl }}/assets/2017-12-05_runners-on-the-spot/img/gitlab-runner.png" alt="GitLab Runner">
</a>

Before we start a few details about the GitLab runners. To execute the builds, GitLab use an agent to orchestrate the build with docker machine. A docker machine creates instances with docker engine to run docker contianers. The first step for setting up a runner is to register a new runner. Currently GitLab does not provide a fully automated way. So the first step is manually.

## Creating infrastructure for the runners
Open you GitLab Project and lookup the token to register a runner. Beware there are project local tokens and global token. Next, we using a docker container to register a runner.
```
docker run -it --rm gitlab/gitlab-runner register
```

<asciinema-player src="{{ site.baseurl }}/assets/2017-12-05_runners-on-the-spot/asciinema/register.json"
  cols="166" rows="15" autoplay="true" loop="true" speed="1.5">
</asciinema-player>

Provide all the requested details, consult the GitLab manual for more details. Once done you should see a new runner registered at your project or globally. Open the runner settings in edit mode and record the token. This token we need later for connecting the agent.

Now we have our runner ready in GitLab we have to create our infrastructure on AWS. I have used AWS networking scenario 2, to build a VPC with a public and private part. See for more details the [post]({{ site.baseurl }}/2017/06/18/terraform-aws-vpc/) about coding a VPC. To create the VPC including a public and private part we add the following module to our `main.tf` file.
```

module "vpc" {
  source = "git::https://github.com/npalm/tf-aws-vpc.git?ref=1.0.0"

  aws_region  = "eu-west-1"
  environment = "ci-runners"

  availability_zones = {
    eu-west-1 = ["eu-west-1a"]
  }
}
```

Next, we create a `t2.micro` instance using an autoscaling group in the private network. On this instance we install and configure the gitlab runner. Configuration of GitLab Runners is done via a `config.toml` file. The content of the file is extracted in a template in terraform. Below the parameterized version of this config file.

```
concurrent = ${runner_concurrent}
check_interval = 0

[[runners]]
  name = "${runners_name}"
  url = "${gitlab_url}"
  token = "${runners_token}"
  executor = "docker+machine"
  limit = ${runners_limit}
  [runners.docker]
    tls_verify = false
    image = "docker:17.11.0-ce"
    privileged = ${runners_privilled}
    disable_cache = false
    volumes = ["/cache"]
    shm_size = 0
  [runners.cache]
    Type = "s3"
    ServerAddress = "s3-${aws_region}.amazonaws.com"
    AccessKey = "${bucket_user_access_key}"
    SecretKey = "${bucket_user_secret_key}"
    BucketName = "${bucket_name}"
    Insecure = false
  [runners.machine]
    IdleCount = ${runners_idle_count}
    IdleTime = ${runners_idle_time}
    MachineDriver = "amazonec2"
    MachineName = "runner-%s"
    MachineOptions = [
      "amazonec2-access-key=${access_key}",
      "amazonec2-secret-key=${secret_key}",
      "amazonec2-instance-type=${instance_type}",
      "amazonec2-region=${aws_region}",
      "amazonec2-vpc-id=${vpc_id}",
      "amazonec2-subnet-id=${subnet_id}",
      "amazonec2-private-address-only=true",
      "amazonec2-request-spot-instance=true",
      "amazonec2-spot-price=${spot_price_bid}",
      "amazonec2-security-group=${security_group_name}"
    ]
```

All variables can be configured and most of them will have defaults. Only the name of the runner, token and GitLab URL needs to be configured. The configuration also contains a shared cache that can be used between builds.

```
module "runner" {
  source = "https://github.com/npalm/tf-aws-gitlab-runner.git"

  aws_region       = "<region-to-use>"
  environment      = "ci-runners"
  ssh_key_file_pub = "<file-contains-public-key"

  vpc_id                  = "${module.vpc.vpc_id}"
  subnet_id_gitlab_runner = "${element(module.vpc.private_subnets, 0)}"
  subnet_id_runners       = "${element(module.vpc.private_subnets, 0)}"

  runner_name       = "<name-of-the-runner"
  runner_gitlab_url = "<gitlab-url>"
  runner_token      = "<token-of-the-runner"
}
```

The complete exmple is in [GitHub](https://github.com/npalm/tf-aws-gitlab-runner/tree/master/example). Next step is to create the runners in AWS. I assume you have AWS keys configured and terraform installed. Execute the steps below to get the runners up and running.
```
git clone https://github.com/npalm/tf-aws-gitlab-runner.git
cd tf-aws-gitlab-runner/example
```
The example directory contains a complete working example that only needs to be configured to your GitLab runner. Please register a runner in GitLab (see docker command above). And update the `terraform.tfvars` file. That is all, now execute the terraform code.
```
# genere SSH key pair
./init.sh

# initialize terraform
terraform init

# apply, or plan first
terraform apply
```

<asciinema-player src="{{ site.baseurl }}/assets/2017-12-05_runners-on-the-spot/asciinema/terraform.json"
  cols="166" rows="15" autoplay="true" loop="true" speed="1.5">
</asciinema-player>


After a few minutes the runner should be running, you should see in your AWS console the runner active.
<a href="#">
    <img src="{{ site.baseurl }}/assets/2017-12-05_runners-on-the-spot/img/ec2.png" alt="Running EC2 instances">
</a>
<br>
In GitLab the runner should now be active as well. Check the runner pages which should now indicates the lates contact of the runner.
<a href="#">
    <img src="{{ site.baseurl }}/assets/2017-12-05_runners-on-the-spot/img/runner.png" alt="GitLab Runner details">
</a>
<br>

You can also inspect CloudWatch where the systemd logging is streamed to.
<a href="#">
    <img src="{{ site.baseurl }}/assets/2017-12-05_runners-on-the-spot/img/cloudwatch.png" alt="CloudWatch logging">
</a>

## Verify

Finally we can start our build. Below a `.gitlab-ci.yml` example to verify the setup is working. The build contains two stages. In the first stage an ascii art image is generated and stored in a file. In the second stage the file is retrieved from the cache.

```

stages:
  - build
  - verify

cache:
  key: "$CI_BUILD_REF"
  untracked: true

image: npalm/cowsay

build:
  stage: build

  script:
    - cowsay -f ghostbusters building "$CI_BUILD_NAME" @ stage "$CI_BUILD_STAGE" > ghosts.txt

  tags:
     - docker.m3

verify:
  stage: verify

  script:
    - cat ghosts.txt

  tags:
    - docker.m3
```

Add the file above to a GitLab repo that has the created runner attached. Once you commit the file a build should triggered. In the logging of the verification step should contain the the ascii art image.

<a href="#">
    <img src="{{ site.baseurl }}/assets/2017-12-05_runners-on-the-spot/img/ghost.png" alt="Build log">
</a>
