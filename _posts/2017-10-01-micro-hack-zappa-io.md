---
layout:     post
title:      "MicroHack Zappa.io"
subtitle:   "A quick test for using the Zappa.io serverless framework to run a python service in the cloud"
date:       2017-10-01
authors:     [jeroen]
header-img: "img/htc-lake.jpg"
tags:       [serverless, microhack, python, aws, cloud]
---

# MicroHack - Python serverless with Zappa.io

## The context

I've visited one of the best conferences last september, Full Stack Fest in Barcelona. Since then, two talks are constantly in the back of my mind.

The first one is the talk by Ben Foxall ([@benjaminbenben](https://twitter.com/benjaminbenben)). He talked about Microhacks and how to become better in your experiments by constraining them. Write small reports / blogs of your Microhacks to so you have a nice overview of some of the experiments you've done. Guess what this blog is about..

The second talk I'm frequently think of was the talk by Rich Jones ([@GUNdotIO](https://twitter.com/GUNdotIO)) titled "Gone in 60 milliseconds: Offensive security in the serverless age". A DDoS attack of slides, 452 in total. The talk main focus was about security and how you can hack the AWS infrastructure if things are not setup correctly. He knows his ways in AWS. That's comes very handy if you want to build a cli which helps other people to run serverless python apps in the cloud. And this is exactly what he's been doing with [https://www.zappa.io](https://www.zappa.io).

## What's the experiment

I wanted to test the cli zappa.io with a simple python Flask app. The specs are simple: A service which reverses an input string running in the cloud with zappa.io. Serverless services are very interesting, because it's based on lambdas and they typically run for a few milliseconds. So the costs are very low, utilization is very high.
I've asked some colleagues to join me on a friday afternoon experiment and [Jos Beijk](https://github.com/13B-MSP) wanted to help. 

## Let's do it!

We need [Python](https://www.python.org/), a package manager ([pip](https://pip.pypa.io)) and a tool to create isolated Python environments ([Virtualenv](https://virtualenv.pypa.io)).
Store your AWS secrets in your `.aws` directory.

If you do not have an AWS account, don't worry. Just signup and the first 1.000.000 requests per month are for free. [https://aws.amazon.com/lambda/pricing](https://aws.amazon.com/lambda/pricing/)

## The experiment

<script type="text/javascript" src="https://asciinema.org/a/139025.js" id="asciicast-139025" async data-speed="2" ></script> 

GitHub: [https://github.com/JeroenKnoops/zappa-string-reverser](https://github.com/JeroenKnoops/zappa-string-reverser)

## What just happened?

### The service
Create a simple `Flask` service which reverses an input string.

``` python
from flask import Flask, request

app = Flask(__name__)

@app.route('/<string:str>', methods=["GET"])
def reverse_str(str):
    return str[::-1]
    
if __name__ == '__main__':
    app.run()
```
### Required libraries
Add required libraries Flask and Zappa in `requirements.txt` so pip can install it.

```
Flask>=0.12
zappa>=0.17.6
```

### Install required libraries in virtual environment
Create a virtaul environment and activate it.

``` fish
virtualenv venv
source venv/bin/activate.fish
```
Note: If you use `zsh` or `bash` you can use: `source venv/bin/activate`

``` fish
pip install -r requirements.txt
```

### Setup Zappa and deploy the service
Setup Zappa:

``` fish
zappa init
```

Once you finish initialization, you'll have a file named `zappa_settings.json` in your project directory defining your basic deployment settings.

Edit this file to add more service specific configurations:
``` json
{
    "dev": {
        "app_function": "string_reverser.app", 
        "keep_warm": false,
        "debug": true,
        "log_level": "DEBUG",
        "aws_region": "eu-west-1", 
        "profile_name": "default", 
        "http_methods": ["GET"],
        "parameter_depth": 1,
        "timeout_seconds": 300,
        "memory_size": 128,
        "use_precompiled_packages": true,
        "s3_bucket": "zappa-<unique-thingy-goes-here>"
    }
}
```

Deploy the app:
```
zappa deploy dev
```

The output is the url to our service. You see it's https out-of-the-box.. :)

### Test our service 
The previous step will output an url to our service. In my case: https://z9cxt9gky6.execute-api.eu-west-1.amazonaws.com/dev/

Append the test string behind it and check the result.
``` fish
curl https://z9cxt9gky6.execute-api.eu-west-1.amazonaws.com/dev/thisisateststring
```

Wiehoe! We got: `gnirtstsetasisiht`

### Update the service
When you want to apply some changes, you can deploy it by running:

```
zappa update dev
```

If you add other libraries, make sure you add it in `requirements.txt` and install it locally in your virtual environment. All the packages in this folder will be shipped.

### Debugging
You can do various things with the zappa cli.

You can view logging for example:
```
zappa tail dev
``` 

See help for more info:
``` 
zappa --help
```

Feel free to check the created services in AWS console. You will see API gateway, CloudWatch and Lambdas.

### Cleanup
Remove the infrastructure by simply undeploy the environment:
```
zappa undeploy dev
```

## Conclusion
Ofcourse this example has no real value, but I wanted to see how it works.
I think zappa.io is very good in its default values, but is extremely flexible.
You don't like the JSON format and prefer YAML or TOML? no problem. Want to run it in a VPC, no problem. Don't like the Keeping The Server Warm settings, you can change it.
Look at [https://github.com/Miserlou/Zappa](https://github.com/Miserlou/Zappa) for the complete list of options. There's good community support with a slack channel, so I would encourage you to look at this project. Especially because you have a lot of good defaults in this setup and this guy knows a few things about AWS.

## Links

- Full Stack Fest - frontend: [https://040code.github.io/2017/09/08/fsf-fontend/](https://040code.github.io/2017/09/08/fsf-fontend/)
- Full Stack Fest - backend: [https://040code.github.io/2017/09/05/fsf-backend/](https://040code.github.io/2017/09/05/fsf-backend/)
- [https://www.zappa.io](https://www.zappa.io)
- [https://github.com/Miserlou/Zappa](https://github.com/Miserlou/Zappa)
