---
layout:     post
title:      "Mob Programming"
subtitle:   "Learnings of a workshop"
date:       2019-03-15
authors:    [stefan]
header-img: "assets/2019-03-15-mob-programming/background.jpeg"
tags:       ["xp"]
enable_asciinema: 1
---
*This blog was originally posted on [Feb 25, 2019][1].*

> Last week I was lucky to be able to attend a workshop about “mob programming”, given by Woody Zuill. As somebody who considers himself “agile” (in the original sense of the word) and who is a proponent of extreme programming, I liked it a lot. In this article I’m sharing some of my findings and learnings.

# Mob Programming

Simply put, it means that the entire team is working on a single computer, all together at the same time. As an outsider, you might see a few big screens next to each other, and team members sitting next to each other facing those screens. One person is behind the keyboard, and the others are looking at the screens. One of them seems to have a special role, because he is telling the person behind the keyboard what to do.

Looking a bit closer, you notice that one person is not really looking at the screens very much, but paying close attention to what the rest are doing. He notices you and quietly comes over to you. He introduces himself as the team’s coach.

*You:* This looks interesting, can you explain what is going on here?

*Coach:* Sure! This team is learning mob programming. They have been at it for a while now and are approaching the point where they don’t need me anymore. They understand how to do it and why they are doing it. They are learning how to improve on this by themselves.

*You:* So why are they doing it?

*Coach:* There are two important reasons. The first is that the team wanted to learn to work together more effectively. They want to have a common understanding of things like architecture, coding standards, and code quality. Before they started working this way, they were in trouble. They were working on a project that was already a year late, and they didn’t know how to make the drastic improvements that were needed. When I was hired, I noticed that cycle times for bug fixes where sky-high: it took forever for a bug that was reported to be fixed. When I looked into the code base and I was not very enthusiastic about the quality. When asking about this to the individual team members, they reacted very differently. Some didn’t feel there was a problem. Others did, but they found they couldn’t address it because the rest of the team “just doesn’t get it”. There clearly was an issue with the team’s ability to operate *as a team* instead of just a bunch of individuals.

*You:* I have seen situations like that myself occasionally. Has it improved?

*Coach:* Oh yes, it can be difficult still sometimes, but they have learned to discuss such issues with each other. They have learned to raise such issues, and they have learned to do that in a respectful manner.

*You:* How did that happen?

*Coach:* I let them play.

*You:* Come again?

*Coach:* Let me ask you a question: what is the most important prerequisite for learning?

*You:* That’s easy. We have known forever; that’s why we don’t allow bullying at schools, for example. It is *security*, the knowing that it’s ok to be wrong, to make mistakes.

*Coach:* Indeed! So that’s what we did. Every Friday afternoon, we’d have a coding dojo together, where we practiced coding kata’s. The word “dojo” comes from martial arts: a place where you practice. A “kata” is a series of made-up exercises designed to help you learn something in a safe situation. And we found that it was so much easier to discuss code quality with each other when we didn’t have the pressure of “work” attached to it! Nowadays, instead of using Friday afternoons for this, we start every day with a coding dojo of an hour. Through this, we have learned to treat each other with kindness, consideration, and respect.

*You:* That sounds like it might not only be effective, but also fun! So you mentioned that there are two reasons for doing mob programming. What’s the other one?

*Coach:* The second reason is even more important than the first one. What harms project progress more than anything else?

*You:* Ehh…

*Coach:* *(gives encouraging look)*

*You:* Well…

*Coach:* Exactly, delays! Waiting time, queues, inventory! This is all very well known from *lean manufacturing*. It is common sense that keeping people busy while waiting for important answers is counter-productive. It’s not about being busy, it is about getting the most important thing done as fast as possible. A waiting time of an hour probably costs at least two hours because of context switching. It’s all about *flow*. Mob programming is a multi-discipline approach. Everybody who is needed should be present, including designers, testers, product owner. And if key people cannot be present, they have to make sure that they are otherwise available and get back to questions within minutes. Unless the project is not important of course, but then you should probably find something else to do.

*You:* Right. It’s surprising how much *lean* is common sense in one discipline, and how novel it appears to be in software engineering.

*Coach:* And it gets better. Because “flow” has another meaning, from the field of psychology. When you’re “in flow”, you are highly concentrated, you forget distractions, every ounce of your mental powers is used to solve the problem at hand. One of the original goals of pair programming was to improve flow: when one of the pair needs to step away for a moment, the other continues. When the first returns, she can get right back into flow again. Mob programming reinforces this even more.

## The Workshop

So that was what the workshop was about: why do it, and how to do it. There was a hands-on coding dojo of a few hours that was designed to get a flavour of what you need to learn as a team to be more effective. I won’t spoil it for you, but to me it struck a good balance between fun and “suffering” (being confronted with things that you didn’t know you were doing ineffectively).

Focussing on *flow* feels like a good idea. When you do that as a team, you can come up with strategies to deal with problems like managers trying to interrupt too often, for example. But also things that need studying can interrupt your flow; you might create a list of study topics to park these things on, and have a dedicated hour of learning every day for those topics (coding dojo!).

There is so much more to talk about. For example, the roles of mob programming and the underlying principle: *all ideas must go from somebody's head into the computer through somebody else's hands*.

Want to learn more? Hire Woody Zuill and/or buy his book “Mob Programming – A Whole Team Approach”. Like what you read? Contact me and let’s see how we can leverage this!

[1]: https://gist.github.com/svdo/0519c26fec9899b9b2c081c1c3d37ff6#file-blog-post-mob-programming-md