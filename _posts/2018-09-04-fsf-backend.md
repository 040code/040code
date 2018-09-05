---
layout:     post
title:      "Full Stack Fest 2018"
subtitle:   "Backend days"
date:       2018-09-05
authors:    [jeroen, niek]
header-img: "assets/2018-09_fullstackfest/kanaal_nre.jpg"
tags:       [iot, cloud, fullstack, microservices, security]
comments:   true
---

# Full Stack Fest 2018

This week we (Jeroen, Niek, Gertjan, Eric and Kike) are enjoying [Full Stack Fest 2018 Barcelona](https://2018.fullstackfest.com/),
a week-long full stack development conference with a focus on solving current problems with new & inspiring perspectives.

In this quite short blog we just summarizing briefly the talks and **our opinion** about the talks. We have rated all talks, the rating is subjective as well.

First of all we would like to thank [Luca Marchesini](https://twitter.com/xbill82) for hosting the sessions.

## Day one

### Reinvent the social web
Rating: :star: :star: :star: :star:

André Staltz ([@andrestaltz](https://twitter.com/andrestaltz)) explained the problems we have with the current generation of social networks. Are the realy open, free, innovative? Can we trust and respect people in the network. He explained passionated how we can change the future with decentralized networks sunch as [scuttlebutt](https://www.scuttlebutt.nz/).


### Open Gateway - Decentralized IoT
Rating:

Kalyan Dikshit ([@decode_dev](https://twitter.com/decode_dev)) presents about the open gateway initiative from Mozilla. Not our topic.


### Build and deploy a Blockchain web-app with Hyperledger Fabric and Hyperledger Composer
Rating: :star: :star: :star:


Hyperledger is something we're looking into right now, so this talk was very relevant. Horea Porutiu ([@horeaporutiu](https://twitter.com/horeaporutiu)) showed the basic things about hyperledger and that's great for this audience. Great balance between technical information, examples and real applications of the chain. Their work with [Brooklyn Roasting Company](https://www.brooklynroasting.com/) was a good example how to use the blockchain. It shows an audit trail on your coffee.


### A Game of Theories: Why languages do what they do
Rating: :star: :star: :star: :star: :star:

Rae Krantz ([@rustbeltrae](https://twitter.com/rustbeltrae)) quickly compared the ugly and beauty of Ruby, Python, Go, Clojure, JavaScript, Erlang, Rust and Elixir. Yeah we never will do Clojure and from tomorrow we only do Rust and Elixir. Awesome session. Best quote of the day: "JavaScript was written in the time of Netscape when Java was popular." :)

### The Future of ChatBots in the Travel Industry
Rating: :star: :star: :star:

Prabh Simran Singh Baweja

Designing a chatbot is not that easy as it sounds. "Book me a hotel for this weekend." What kind of hotel? Where? Weekend, is it friday and saturnday or is it saturday and sunday? How to combine data in a good way so people are not annoyed. Nice insights on how bookings.com is building these bots.
Look at [his slides](https://speakerdeck.com/prabh27/the-future-of-chatbots-in-the-travel-industry)


### Avoiding Digital Bias
Rating: :star: :star: :star: :star:

Adam L Smith ([@adamleonsmith](https://twitter.com/adamleonsmith))

In modern worlds we use large datasets to tune our models. This is not without danger. Our datasets are often biased. Good tips on how to test if the models are digitally bias, by changing some of the fields like gender. Never use stock images. Nice example was shown if you google on CTO. This is not a good representation of the world. Enough food for thoughts!

### Everything I always wanted to know about crypto, but never thought I'd understand
Rating: :star: :star: :star:

Sasha Romijn ([@mxsash](https://twitter.com/mxsash)) gave a fast introduction to cryptographic basic concepts that every developer should know. Quote: "Export in cypher builder should ring an alarm bell"
A good overview of the magical world of Crypto. If you want to learn more about this, I would certainly recommend a free [coursera course on this topic](https://www.coursera.org/learn/crypto) given by Dan Boneh.


### Onion adventures: how to use onion services and the Tor network in your web endeavors
Rating: :star: :star: :star:

Respect for Silvia Puglisi ([@nopressure](https://twitter.com/nopressure)) for giving this talk when she has the flu. Very good to see all the activity around Tor. Important to keep on bringing the message it's not that obvious to have freedom of speech and expression. /me installing TOR.


### Everything in sketchnotes..
A big shoutout to Christin Westermann ([@_c16n_](https://twitter.com/_c16n_)) for creating these sketchnotes!

<a href="#">
    <img src="{{ site.baseurl }}/assets/2018-09_fullstackfest/fullstackfest-2018-01.jpg" alt="fullstackfest-2018-01">
</a>

<a href="#">
    <img src="{{ site.baseurl }}/assets/2018-09_fullstackfest/fullstackfest-2018-02.jpg" alt="fullstackfest-2018-02">
</a>


## Day 2

### Observability for Emerging Infra: What Got You Here Won't Get You There
Rating: :star: :star: :star: :star:

Charity Majors ([@mipsytipsy](@https://twitter.com/mipsytipsy)) gave a very good talk on how to look at current systems. In the current era, you cannot simply say: "Our application is up.." What does that mean? What's up? Move away from the known-unknowns which can be monitored with dashboards, but look at the real problems users experience. Focus on the unknown-unknowns and make sure you can react and analyse your applications fast. Don't aggregate data, because you will lose important details about problems. Come up with good sampling strategies. Build observability in from day one! Cool shirt, "I test in prod". Quote: "What is unknown, we must leave uncoded."


### Do you need a Service Mesh?
Rating: :star: :star: :star: :star:

A great presentation given by Matt Turner ([@mt165pro](https://twitter.com/mt165pro)) about Service Mesh. He demo-ed the principles of Service Mash by using [istio.io](https://istio.io/). He used kubernetes to demo some of the configuration you can setup with only proxy-ing between different services. Very powerful concept. I'm wondering how this can be used in an infrastructure-as-code architecture.


### HTTP and JSON for your gRPC Services
Rating: :star: :star: :star: :star:

Michael Hamrah ([@mhamrah](https://twitter.com/mhamrah)) gRPCed all the things. First feeling was Oh no we go to do again CORBA, and there are similairities between gRPC and CORBA. In this talk Michael explained how you can build high performance application and left the all the plumbing code to the gRPC framweork. Just simply define an interface via IDL and only take care of the real business code. It was also nice to see how you can combine gRPC via [rejoiner](https://github.com/google/rejoiner) with GraphQL. Slides are available [here](https://speakerdeck.com/mhamrah/grpc-all-the-things)


### Software Engineering - A philosophical activity
Rating: :star: :star: :star: :star:

Tom Enden ([@tom_enden](https://twitter.com/tom_enden)): Did you know that Plato invented OOP and the Prototype pattern is inspired by Nominalism which also dates back to Plato. Tom showed the parallels between philosophy and software engineering. According the pragmatic programmer we should learn at least one language every year. Since different languages solved things in different ways. And Tractatus says the limits of my language means the limit of the world. So looking on philosophy we can inspire our selves for new ideas.


### Take a (Client) Hint!
Rating: :star: :star: :star: :star:

Jeremy Wagner ([@malchata](https://twitter.com/malchata)) explained nicely the power of client hints. Having a fast internet and reliable internet connection is still not common. For example a survey by Pew Research shows that one-third of American adults do not subscribe to any internet access faster than dial-up at their home. So building responsive clients on slow or unreliable networks still counts. Client hints comes in different types. By opting in (header `ACCEPT-CH`) a client can inform that it understands client hints, Device hints enables for example responsive images and netwrok hints can inform the server about the speed of the network of the client. The slides are [here](https://jlwagner.net/talks/take-a-client-hint/) available.


### Lost in transaction? Strategies to deal with (in-)consistency in distributed systems
Rating: :star: :star: :star: :star:

Bernd Rücker ([@berndruecker](https://twitter.com/berndruecker)) is a (work-)flow automation enthusiast. He explained the strategies to deal with the temporary inconsistency and how you can convert it to consistency again using the starbucks as example. One can use different approaches to it. Chorography vs orchestration.
These kind of problems can be solved by using a BPMN product like Camunda. System become complexer every day and this will become a bigger problem everyday. And what should we never forget: Zucchini and idempotency.

This talk triggered a lot of thoughts for me personally. This is one of the areas where blockchain might actually solve things. Use smartcontracts to atomically commit transactions all at the same time. Fortunately he already wrote a blog post about the topic. Great speaker!
[Bernd Ruecker's blog](https://blog.bernd-ruecker.com/)


### Lightning talks
Antiona Librada ([@antoniolibrada](https://twitter.com/antoniolibrada)) showed us how he improved a complex ci build pipeline which took > 45 minutes to run by using 2 lambdas and Amazon Code Build. The outcome was a more stable, cheaper and faster build pipeline. They increased the number of daily deployments drastically.

Peter van der Meulen ([@HendrikPetertje](https://twitter.com/HendrikPetertje)) showed us his terminal. This shows again how important improving your daily workflow is. Some highights: Spotify in Vim, thefuck, circleci-cli, wee-slack. For more info: [snippets](https://git.picodevelopment.nl/explore/snippets) and [projects](https://git.picodevelopment.nl/explore/projects)

Aaron Bassett ([@aaronbassett](https://twitter.com/aaronbassett)) showed us some amazing (and probably illegal) things about SMS. [Here](https://speakerdeck.com/aaronbassett/stupid-and-possibly-illegal-stuff-you-can-do-with-sms-but-probably-shouldnt) you can find his slides. Really scary.

Two nice talks on our power as developers to shape the world. Let's do this right this time.


### Cats, The Musical! Algorithmic Song Meow-ification
Rating: :star: :star: :star: :star:

Awesome to see how Beth Haubert ([@haubertdashery](https://twitter.com/haubertdashery)) passionated hacked her way around to generated a cat meow song from songs using ruby. It was really fun to see, how the program evolved! Especially because at the end, the result was really terrible..

### Everything in sketchnotes..

A big shoutout to Christin Westermann [@_c16n_](https://twitter.com/_c16n_) for creating these sketchnotes!

<a href="#">
    <img src="{{ site.baseurl }}/assets/2018-09_fullstackfest/fullstackfest-2018-03.jpg" alt="fullstackfest-2018-03">
</a>

<a href="#">
    <img src="{{ site.baseurl }}/assets/2018-09_fullstackfest/fullstackfest-2018-04.jpg" alt="fullstackfest-2018-04">
</a>
