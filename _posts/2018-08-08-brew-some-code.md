---
layout:     post
title:      "Brew your code"
subtitle:   "How to create a brew package"
date:       2018-08-08
authors:     [jeroen]
header-img: "img/strijp-s-ols.png"
tags:       [microhack, mac, brew]
---

Working on a Mac made my work a lot more fun. Especially when I was introduced to [homebrew](https://brew.sh/), the missing package manager for macOS.

MacPorts was fine, but it felt clumsy. Every tool seems to be switched to Homebrew and life was good.. Except when you encounter that one tool you need but is not available in brew....

## Meet Gits
An example of this is the great shell script made by Roy Lines: [gits](https://github.com/roylines/gits).
A shell script to share contribution between two git accounts when pair programming.

Unfortunately you have to install it by getting a remote bash script and add it in your /usr/local/bin directory with root rights.

```
$ sudo wget https://raw.github.com/roylines/gits/master/gits.sh -O /usr/local/bin/gits
$ sudo chmod ugo+x /usr/local/bin/gits
$ gits
```

More people did not like that. An [issue](https://github.com/roylines/gits/issues/6) was raised with a question whether it could be installed with homebrew..

> How can it install it on mac? I would prefer to use homebrew.

Well, let's help him!

## Create our own tap

### Correct format

First step is to change the structure of your script so it can be used for brew.
Scripts need to be in the `bin/` directory so that is the first thing we need to do.

https://github.com/JeroenKnoops/gits/commit/4de9197fe1e24b751af2a1fe214b4259bf256c49

### Release the script

You have to create a release of your script. You can do that by [drafting a new release](https://github.com/JeroenKnoops/gits/releases)

Once you have a release browse to it and copy the tar. f.e. `https://github.com/JeroenKnoops/gits/archive/0.1.0.tar.gz`

Download the tar and generate tha SHA-256.

```
$ wget https://github.com/JeroenKnoops/gits/archive/0.1.0.tar.gz
$ shasum -a 256 0.1.0.tar.gz
13b778bf5a7f92285f54179cd88bea4b39f661a3de47a7ff0a84b9aa5d865962  0.1.0.tar.gz
```

We will need this sha256 for our formula.

### Define the Formula

We have to define the formula. This can be done by creating a repo called [homebrew-tap](https://github.com/JeroenKnoops/homebrew-tap)
It's best practice to put some information in the README of this repo about the Formulas which are defined.

In the `/Formula` directory you must create a ruby file with the definition, in our case: [gits.rb](https://github.com/JeroenKnoops/homebrew-tap/blob/master/Formula/gits.rb)

```
class Gits < Formula
  desc "A shell script to share contribution between two git accounts when pair programming."
  homepage "https://github.com/jeroenknoops/gits"
  url "https://github.com/JeroenKnoops/gits/archive/0.1.0.tar.gz"
  version "0.1.0"
  sha256 "13b778bf5a7f92285f54179cd88bea4b39f661a3de47a7ff0a84b9aa5d865962"

  def install
    bin.install "bin/gits"
  end
end
```

Push the repo to github and we're ready to go.

### Test it.
Now people can use the script by installing it with homebrew.
It's still in my private homebrew-tap, so people first have to tap into our private tap.

```
brew tap jeroenknoops/tap
```

After that they can install gits with `brew install gits`

## I want it to be available in without having to tap into someones tap.

You can also put the Formula directly into the [homebrew-core](https://github.com/Homebrew/homebrew-core) so people don't need to tap into someones private tap.
This will require some extra steps, like adding tests.

Brew has a way to test your formula by doing: `brew audit --new-formula gits`

This will show you what you still need to do, before you can submit it to homebrew. You can also find more information on that in the [Formula-Cookbook](https://docs.brew.sh/Formula-Cookbook)

## Improvements.

There are more improvements I should make to release it to homebrew. F.e. add dependencies to `git`.
For now I'm not going to dive into that. Homebrew has good documentation on that: https://docs.brew.sh/Formula-Cookbook 

## More info
- https://docs.brew.sh/How-to-Create-and-Maintain-a-Tap
- https://docs.brew.sh/Formula-Cookbook




