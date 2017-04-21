---
layout:     post
title:      "Periodic builds in GitLab"
subtitle:   ""
date:       2017-04-01 12:00:00
author:     "Niek Palm"
header-img: "img/klokgebouw.jpg"
tags: [gitlab, docker]
---

I am using GitLab CI now for more then a year and I realy love the features in GitLab. GitLab provides a complete and powerfull tool for day to day development. And of course there are alwasy feature that you miss. So is there currently no support for periodic builds.

You could argue why you should need a feature as a periodic build. Ideally a build shoulb be immutable and only trigger by a change in GIT, a commit. But the world is not always perfect, project build are somtime not of the quiltiy that you are expect or tools ar not that reliable as you hope. For example dependencies resolving could break over the time, to avoid you find the problem once your boss is watching you when fixing a critical bug, a periodic build can alert you earlier. Another and much better reason to aruge for the featur is that the GitLab build are so powerfull that is heandy to use them for a scenario based health check.

## The build trigger
To setup a periodic build you first need to be able to trigger a build in some way. GitLab provides an [API](https://docs.gitlab.com/ce/ci/triggers/) to trigger a build. Setting up the trigger is simple and complete guided in GitLab, just execute the steps below:

- Go to your GitLab projects
- Navigate to Settings -> CI/CD Pipelines
- Scroll down to the trigger section and create a trigger
- Make a note of the TOKEN and trigger URL. An curl example for trigger is shown as weell.

<a href="#">
    <img src="{{ site.baseurl }}/img/gitlab-trigger.png" alt="GitLab trigger">
</a>

Now we have a way to trigger the build it is time to test it. Execute the command below and replace TOKEN, REF_NAME and URL.

```
curl -X POST \
     -F token=<TOKEN> \
     -F ref=<REF_NAME> \
     <URL>
```

Verify in GitLab the build is triggers.
we are able to trigger a build we have to create a way to trigger it periodcally. A standard way is by a crontab. To trigger the build periodcally we create a docker images that we deploy every where and will trigger our builds.

I have create a base docker image that contains a script to trigger GitLab by executing a curl command. The crontab will be copied to the image ONBUILD. The script to trigger a container can be used as follow:
```
trigger-gitlab.sh -t <token> -r <ref> -u <gitlab_trigger_url>
```
For all sources see [npalm/gitlab-periodic-trigger](https://github.com/npalm/gitlab-periodic-trigger) on GitHub.

Let's crate our own docker image now all the basic peaces are ready. Create a Dockerfile that only extend the base image.
```
FROM npalm/gitlab-periodic-trigger:1.0.0
```

Next we create a [crontab](https://en.wikipedia.org/wiki/Cron) to trigger the build periodic. Create a file named `gitlabcrontab`. Add one ore more triggers, an example is below.

```
# Example of job definition:
# .---------------- minute (0 - 59)
# |  .------------- hour (0 - 23)
# |  |  .---------- day of month (1 - 31)
# |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
# |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7)
# |  |  |  |  |
22 11 * * * trigger-gitlab.sh -t <token> -r <ref> -u <gitlab_trigger_url>
```
Now we build the container `docker build -t periodic-trigger .` and finally start the container `docker run -d periodic-trigger`
