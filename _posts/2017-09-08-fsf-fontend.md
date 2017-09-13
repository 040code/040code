---
layout:     post
title:      "Full Stack Fest 2017"
subtitle:   "Frontend days"
date:       2017-09-08
author:     "Jeroen Knoops and Niek Palm"
header-img: "img/graffiti-hooftlaan.jpg"
tags:       [aframe, serviceworkers, css, javascript, ast, svg, blockchain, react]
---

# Full Stack Fest 2017

This week we (Jeroen and Niek) enjoyining [Full Stack Fest 2017 Barcelona](https://2017.fullstackfest.com/),
a week-long full stack development conference with a focus on solving current problems with new & inspiring perspectives.

In this quite short blog we just summarizing briefly the talks and **our opinion** about the talks. We have rated all talks, the rating is subjective ass well.

The last days are more frontend focussed read [here](https://040code.github.io/2017/09/05/fsf-backend/) more about the backend days.

## Day four

### Keynote
Rating: :star: :star: :star:

Jenn Schiffer ([@jennschiffer](https://twitter.com/jennschiffer)) showed how to make coding actually friendly with [glitch](https://glitch.com/). And remember once you got bored you will not trying new cool stuff which makes you even unhappier and so on... And some cool [pixel art](http://jennmoney.biz/)

### Once you go PRPL...
Rating: :star: :star: :star: :star:

Service Workers by Houssein Djireden ([@hdjirdeh](https://twitter.com/hdjirdeh)) are stable and most serious browsers support them. SWs are a big help in improving the experience for the user. `Workbox-cli` is a great for configuring your app to cache usefull stuff only. Don't cache too much. `FoamTree` and `webpack-bundle-analytics` show a good overview what to cache. Split up your js, with http/2, we do not need one big js file. React has good SW support.

### Magic tricks with css houdini
Rating: :star: :star: :star: :star:

Absolutely awesome to see the future already working in this talk by Sam Richard ([@Snugug](https://twitter.com/Snugug)). A lot of visual stuff is currently blocking the main JS thread. With Houdini CSS a lot of css stuff can be handle on Worklets. 'Much like Service Workers are a low-level JavaScript API for the browser's cache Houdini introduces low-level JavaScript APIs for the browser's render engine'. Currently only available in Chrome Canary and the definition of unstable, but ooooh so beautiful, [slides in canary](https://snugug.github.io/magic-tricks-with-houdini/#/0/0)

### Master the art of the ast (and take control of your js)
Rating: :star: :star: :star:

Talk by Sears israel ([@cowchimp](https://twitter.com/cowchimp)) to understand most JS libraries you only need to know two things. AST and the visitor pattern. With this knowledge you can easily add ESLint, create Babel plugins or add jscodeshift refactor modules. A great tool to help with AST is https://astexplorer.net

### SVG can do that?!
Rating: :star: :star: :star: :star: :star:

Awesome what you can do with SVG by Sarah Drasner ([@sarah_edo](https://twitter.com/sarah_edo)). This girl really knows her stuff. SVG is supported by all browsers including Opera Mini! Good integration with VueJS, react and other modern frameworks is possible. Lots of examples of really beautiful animations all working for all types of devices. Size does matter for images and animations. Normally it will result in ugly things, but with SVG this is absolutely not the case, [slides](http://slides.com/sdrasner/svg-can-do-that#/).

### Using react native + clojurescript to launch ios/android apps to 1m users
Rating: :star: :star:

A long intro to `react native`, which is most likely not necessary on this conference. A nice twist with `closureScript`. The code looks very clean. It is possible to create apps for both iOS and Android with a 99% simular codebase. The crashlogs of apps created with closurescript and reactnative are unfortunately almost not readible. This set of tools is also great to use in combination with `codepush`. Now we can update the app on the fly without bothering appstores. Talk by Emin Hasanov ([@hasanove](https://twitter.com/hasanove))


### Blasting react into space: building fluid, beautiful interfaces with react and webgl (and other exotic explorations)
Rating: :star: :star: :star: :star:

A good talk by Chad Ostrowski ([@chadoh](https://twitter.com/chadoh)), on how all the new technologies can help us in the future when live is possible on Mars. Using: `HTTP/2`, `ServiceWorkers`, `LocalStorage`, `Bittorent + git`, `IPFS`, `blockchain`, `bitcoin`, `ethereum`. "Tomorrow's problems === Today's problems but bigger." Last year a simular talk was told on FSF, but it's good to see that the technologies mentioned then are now in a much further state. Great talk and good choice from the organiser of this beautiful conference.

<div style="position:relative; width:100%; height:0px; padding-bottom:56.25%;">
    <iframe style="position:absolute; left:0; top:0; width:100%; height:100%"
        src="https://chadoh.github.io/online-offline-equivalence/">
    </iframe>
</div>

## Day five

### Bringing back the 1990s: The revenge of javascript stylesheets
Rating: :star: :star: :star:

Steve Kinney ([@stevekinney](https://twitter.com/stevekinney)) did a lot of work in getting the Javascript Stylesheets, a technology only working in 1996 in Netscape 4) to work in 2017. In the beginning of the internet, people were debating about the split of concern regarding content and layout. One of the proposals was Javascript Stylesheets. Netscape 4 was the only browser capable of this feature. Steve showed us how we can do some really neat stuff in 1996 technology. A lot of this, we now take for granted, but we have to keep in mind that this was 1996. A lot of simularities with SASS, LESS, but also REACT like structures with the [ECMA E4X for XML proposal](https://en.wikipedia.org/wiki/ECMAScript_for_XML). Conclusion: We still can learn from the past. Although some good initiatives take 20 years to become meanstream.

### Rendering performance from the ground up
Rating: :star: :star: :star:

Good presentation about how we can improve the performance a lot by using the GPU instead of CPU. A good explaination what the differences are between a CPU and GPU. Try to use translate and shaders because they don't require repaintings. Thanks Martin Splitt ([@g33konaut](https://twitter.com/g33konaut))!, [slides](https://t.co/oFDjyf5Bb6)

### Web based virtual reality
Rating: :star: :star: :star:

Shagufta Gurmukhdas ([@shaguftamethwan](https://twitter.com/shaguftamethwan)) give a good talk ok the Web based virtual reality. Starting WebVR with WebGL is very hard. She showed us [A-Frame](https://aframe.io). A-Frame was already mentioned three times in FSF, so we were already very curious about it. You can easily start your own VR world with this framework. It uses GPU under the hood and you can use one of your favourite webframeworks (vueJS, React, and so on) to change properties of the 3D models. Very impressive. With this tool, even the most suburn backenders, (we) can start with VR.

### Exploring the world of decentralized networks with webRTC
Rating: :star: :star:

Nikita Baksalyar ([@nbaksalyar](https://twitter.com/nbaksalyar)) started his talk with some technical issues, but he recovered quickly from that. Nikita tought us about how the internet can truly be implemented the way it was supposed to be implemented. Decentralised! Now-a-days we're using a lot of things which are ment to be decentralised in a centralised way. Git and the internet are a nice examples of that. Serving the web, securely and encrypted, with webRTC through all client devices will make it imposible to censor the internet by governments. During the Q&A a question come up on what to do with unwanted content. The response of Nikita was amazing. We should educate people that they don't want to see unwanted content instead of putting the responsibility of this on technology, [resources](https://gist.github.com/nbaksalyar/cfee2bdac7cd0f66e0a91af9621ab264)

### Developing for the next billion
Rating: :star: :star: :star:

Look to your target group. Keep in mind that your apps might not be used by the people you've targetted on. Natalie Pispistunovich ([@nataliepis](https://twitter.com/nataliepis)) showed some examples from Kenya. What apps are used and why. The delivery of apps can be very different from ours. The way payments are done also.
Nice reference to [Fun with Flags](https://www.youtube.com/watch?v=hjzRbgxZXz8)

### Progressive web apps and the internet of things
Rating: :star: :star:

A story of with amongst other libraries, the `johnny-five` library. Today it's easy to communicate with all kind of device with `nodeJS`. Well done, Luis Montes ([@monteslu](https://twitter.com/monteslu))

### Lightning talks

1. PAKO a zlib for uploads in js. For uploading large files. :) NICE. @bombasarkadian
2. DevTools in Firefox: Alex Lakatos @lakatos88;  BASIC
3. Internet for Everyone. Tom Enden en Liran Kurtz. Accessible. GOOD
4. Marek - ProRouter.js - Router.maniak.pro - No idea what this is all about.
5. Kirill Pimenov - Rust! Go write to Rust and go back to your own language and you will be beter. Awesome!
6. Raj - iOS Event Communication without internet, API and no loss of data. Way to fast. OMG... Peer to Peer connectivity with iPhone through Bonjour protocol
7. Paulo -  Functional Programming: Elixir and Phoenix. I love Phoenix! See also [git](https://paulodiniz.github.io/flappy-bird)
8. FSF designer. Uses emoiji as classes. Awesome way of keeping the names short and compact. Really high quality frontend work. See [Full Stack Fest web page](http://2017.fullstackfest.com) and Inspect the code!

### Making a lot of things
Rating: :star: :star: :star:

Ben Foxall ([@benjaminbenben](https://twitter.com/benjaminbenben)) gave us two talks for the price of one!
[https://cojs.co](https://cojs.co) is collaborate platform were people can co-create software. With blocks you can split the code. Adding a `!` behind the url will fork the code. Other users can continue on the code in their own context, but with shared code. Awesome. The second part was about Microhacks. He explained how you should constrain your experiments to make them work. Plan your goal, not your work. Start it and finish it.


## Awesome!!!
Many thanks to [Codegram](https://www.codegram.com/) the company that organized once again the best conference!
