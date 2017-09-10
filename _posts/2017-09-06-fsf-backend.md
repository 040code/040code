---
layout:     post
title:      "Full Stack Fest 2017"
subtitle:   "Backend days"
date:       2017-09-05
author:     "Jeroen Knoops and Niek Palm"
header-img: "img/daf.jpg"
tags:       [iot, cloud, fullstack, microservices, security]
---

# Full Stack Fest 2017

This week we (Jeroen and Niek) enjoyining [Full Stack Fest 2017 Barcelona](https://2017.fullstackfest.com/),
a week-long full stack development conference with a focus on solving current problems with new & inspiring perspectives.

In this quite short blog we just summarizing briefly the talks and **our opinion** about the talks. We have rated all talks, the rating is subjective ass well.

The first two days are more backend focussed, the last two days have a frontend focus, read more [here](https://040code.github.io/2017/09/08/fsf-fontend/).

## Day one

### Keynotes - Science - Backup the internet
Rating: :star: :star: :star: :star:

Karissa McKelvey ([@okdistribute](https://twitter.com/okdistribute)) discussed the topic to share fairly large data sets in the science community in a secure and distributed way. The [dat project](https://docs.datproject.org/) enables file sharing via peer to peer for example with the beaker browser.

### Ehtereum, aeternity and the distributed wonders
Rating: :star: :star: :star: :star:

Luca Marchesini ([@kuzzleio](https://twitter.com/kuzzleio)) did a great job by explanining about blockchain and the differences between ethereum and bitcoin. Blockchain; the system where playing by the rules is more profitable than cheating.

### Terraform in your delivery pipeline
Rating: :star: :star:

We love the Terraform framework of HashiCorp but the talk not as good as we hoped, nothing new. The speaker Anton ([@antonbabenko](https://twitter.com/antonbabenko)) is an expert on the topic and also maintains some great [Terraform modules](https://github.com/terraform-community-modules).

### Migrating an existing service to serverless
Rating: :star: :star:

For us a standard talk by Marcia ([@mavi888uy](https://twitter.com/mavi888uy)) about migrating an existing monolitic applicaton to smaller components. We loved all the (angry) birds flying around.

### Defending the human network
Rating: :star: :star: :star: :star:

Good story about cyber security by Dr. Jessica Barker ([@drjessicabarker](https://twitter.com/drjessicabarker)). About how the mood of a user is one of the weakest link. How you can trick people into clicking a bad links. Socially engineering and use stress full situation let a user execute an (maybe) unwanted action.

Key take aways, learn to think as hacker and focus on the why not on how to enforce / restrict users to do something.


### Rise and the fall of the full stack database
Rating: :star: :star: :star: :star:

Comparison with the army knife. Don't be afraid of new technologies.
One tool for everything is not going to work.
Example with analytics service, kafka stream, bus. Frank Lyaruu ([@lyaruu](https://twitter.com/lyaruu)) did a great job!

### How booking.com serves deep learning model predictions
Rating: :star: :star: :star:

Good explaination by Sahil ([@sahildua2305](https://twitter.com/sahildua2305 )) about how to train a model and how to deploy them.

### What to do when complex systems fail
Rating:

Not relevant to our needs.

## Day Two:

### The internet of things: An army of devices ready for DDoS
Rating: :star: :star: :star: :star:

Good talk by John Graham-Cummin ([@jgrahamc](https://twitter.com/jgrahamc)) about how IoT device can be used to do a DDoS attack. About port 1900 showing all kinds of information which is sent to victims address. How to block DDoS attacks by putting the ip-address in a grid to search for patterns. Talked about Trump attacks and anonymous being stupid by setting the evil flag (We're anonymous).

### How to properly blame things for causing latency: An introduction to distributed tracing and Zipkin
Rating: :star: :star:

Difference between logs, metric and trace. Good (known) story by Adrian Cole ([@adrianfcole](https://twitter.com/adrianfcole)).

### Ship more, sink less. Changing chaos engineering & Distributed tracing
Rating: :star: :star:

The story about testing in real live situations is not new, good te remember the importance to be prepared for failure. For not much new things in this talk since we here the chaos monkeys stories new for a couple of years. But we will plan our Chaos GameDay soon. Thanks to Aish ([@aishrajdahal](https://twitter.com/aishrajdahal))

### Flying Spaghetti monster: Verifying protocols with types and finite-state machines
Rating: :star: :star: :star: :star:

Complexity of systems cause a lot of problems. `Idris` has a nice feature that Types are also values, so state changes can easialy be checked in compile time. `talk.applaud()` should only run after `talk.give()` and Idris has a way to check this easily during compile time.

Inspiration for doing more with new languages. Chris Ford ([@ctford](https://twitter.com/ctford)), thanks!

### Smart grid: How iot fights climate change
Rating: :star:

Kelsey Breseman ([@ifoundtheme](https://twitter.com/ifoundtheme)) explains us how complex the eletrical grids works which makes it hard as well to safe for example solar eneregy. It was great to hear the complecity of this relevant topic but unfortunately there was not much relation betwoon the world of of software.

### Beyond patterns: Technological systems and the nature of order
Rating: :star: :star: :star: :star:

Good to see the that our hipster shit is the same as the problems the manufacturing has already solved. Learn from that! Talk by Jerome Scheuring

### Lighting Talks
Rating: :star: :star: :star:

There where quite a lot fo lighting talks. In our opinion: hight quality but too many.

- Docker talk about `docker build` was fun. Docker build takes long, and from now on I can't ignore it anymore. THANKS!!! aka we should fix the layer thing.
- Fullstack is a zoo. Complexity of our work environment.
- [http://exercism.io/](http://exercism.io/): Nice code kata kind of thing. (not a talk, but worth to mention)

### Gone in 60 milliseconds: Offensive security in the serverless age
Rating: :star: :star: :star: :star: :star:

Awesome DDoS attack of slides by Rich Jones ([@GUNdotIO](https://twitter.com/GUNdotIO)). A lot of cool stuff. A very usefull and insight talk about how unsecure you serverless application can be. Serverless python with [zappa](http://zappa.io) and [slides](https://rawgit.com/Miserlou/Talks/master/full-stack-barcelona-2017/stack.html)
