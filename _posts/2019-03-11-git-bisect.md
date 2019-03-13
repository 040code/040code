---
layout:     post
title:      "Git Bisect"
subtitle:   "Find the bug-introducing commit with Git Bisect"
date:       2019-03-12
authors:    [jeroen]
header-img: "assets/2019-03-11-git-bisect/background.png"
tags:       ["git", "rust"]
enable_asciinema: 1
---

I want to tell you a little story about what happened to me a few days ago.
I went to the office and a colleague of mine was not very happy. This is strange because I work for a very nice company.. What happened? I asked him what was wrong. It turned out that he updated a lot of dependencies and some code for a certain service. And now the SonarQube reporting was not working anymore with a very strange message: HTTP Error 502 Bad gateway.. 

I decided to help him, because we don't work alone and especially when you're stuck (and frustrated) at something it's best to include other human beings.

Since there we're already several commits done I've decided to use `git bisect` to find the bug-introducing commit.

I've noticed that it was new to my colleague so let's write a blog post about it.

## Prerequisites

In order to follow the instructions, you need the following things:
- [Git](https://git-scm.com/downloads) - Duh... This blog is about Git!
- [Rust & Cargo](https://doc.rust-lang.org/cargo/getting-started/installation.html) - The best language ever I'm NOT using in my daily work.  
- Clone [https://github.com/JeroenKnoops/rust-example](https://github.com/JeroenKnoops/rust-example). This is an example codebase with a bug we want to find.

## Rust example
The rust-example is very simple. It's a rust library with four functions namely: `add`, `substract`, `multiply` and `division`. By no means this should ever be used in real systems, this repo only exists as example for this blog post. It has 9 commits. 

```
$ git log --pretty=format:"%h - %an, %ad : %s"
4d7f719 - Jeroen Knoops, Sun Aug 12 17:10:07 2018 +0200 : Adds link to blog post on git bisect
380d12e - Jeroen Knoops, Sun Aug 12 17:09:04 2018 +0200 : Refactors tests in seperate directory
1ae37e1 - Jeroen Knoops, Sun Aug 12 17:07:32 2018 +0200 : Adds edge cases for division
0580aec - Jeroen Knoops, Sun Aug 12 17:06:41 2018 +0200 : Adds information on how to run tests and create the documentation
d619b4d - Jeroen Knoops, Sun Aug 12 17:04:50 2018 +0200 : Adds function 'division'
abc4c40 - Jeroen Knoops, Sun Aug 12 17:03:29 2018 +0200 : Adds function 'multiply' with a runnable example in the documentation
2a5a057 - Jeroen Knoops, Sun Aug 12 17:01:27 2018 +0200 : Adds readme.md
3d75d3d - Jeroen Knoops, Sun Aug 12 16:59:58 2018 +0200 : Adds travis-ci pipeline
030b725 - Jeroen Knoops, Sun Aug 12 16:58:49 2018 +0200 : Adds functions 'add' and 'substract'
```

It starts with adding two functions, adding travis-ci, add some documentation, more functions, some refactoring... everything you expect from a 'real' project.

Of course it has some tests and I've tested everything manually before I commit... But for some reason at the end, the `substract` function is not working anymore..
Whoops.. I've tested it manually, but for some reason I've forgot to add a test for it..

## Let's create a test 

We're creating a test in `/tests/bug.rs` to show the bug.
We will use this test to check in which commit the bug was introduced.

```rust
extern crate example;
use example::*;

#[test]
fn test_substract() {
      assert_eq!(substract(8, 2), 6);
}
```

Now try to run this test in isolation with the following command:
```bash
cargo test --test bug
```

Test on `master` should fail:
<asciinema-player src="{{ site.baseurl }}/assets/2019-03-11-git-bisect/git-bisect-1.json"
  cols="166" rows="18">
</asciinema-player>

Test on first commit (`030b725`) should not fail:
<asciinema-player src="{{ site.baseurl }}/assets/2019-03-11-git-bisect/git-bisect-2.json"
  cols="166" rows="18">
</asciinema-player>

Somewhere in between it start not working anymore.. Let's use `git bisect` to find that.

## Git bisect
We go back to the `master` with the added test.

We start the bisect procedure:

```bash
git bisect start
```

We tell bisect that the current version is *bad*:
```bash
git bisect bad
```

Now we tell bisect the commit of a known working version:
```bash
git bisect good 030b72500f08774b685c59c3e5ddd64afce432f1
```

We tell bisect to look when the bug appears:
```bash
git bisect run cargo test --test bug
```

After the test, reset the HEAD to the first place.
```bash
git bisect reset 
```

Let's see this in action:
<asciinema-player src="{{ site.baseurl }}/assets/2019-03-11-git-bisect/git-bisect-3.json"
  cols="166" rows="18">
</asciinema-player>

What did just happen?

```
 git bisect run cargo test --test bug
running cargo test --test bug
   Compiling example v0.1.0 (file:///Users/software-concepts/workspace/jeroen.knoops/rust-example)
    Finished dev [unoptimized + debuginfo] target(s) in 0.58 secs
     Running target/debug/deps/bug-6262d8198d8b39aa

running 1 test
test test_substract ... FAILED

failures:

---- test_substract stdout ----
	thread 'test_substract' panicked at 'assertion failed: `(left == right)`
  left: `16`,
 right: `6`', tests/bug.rs:6:5
note: Run with `RUST_BACKTRACE=1` for a backtrace.


failures:
    test_substract

test result: FAILED. 0 passed; 1 failed; 0 ignored; 0 measured; 0 filtered out

error: test failed, to rerun pass '--test bug'
Bisecting: 1 revision left to test after this (roughly 1 step)
[2a5a0578f44883d360287fc771c9d1dd7cff4cd6] Adds readme.md
running cargo test --test bug
   Compiling example v0.1.0 (file:///Users/software-concepts/workspace/jeroen.knoops/rust-example)
    Finished dev [unoptimized + debuginfo] target(s) in 0.59 secs
     Running target/debug/deps/bug-6262d8198d8b39aa

running 1 test
test test_substract ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out

Bisecting: 0 revisions left to test after this (roughly 0 steps)
[abc4c40d4a06711bab5039a2896db3f67d8ddd0e] Adds function 'multiply' with a runnable example in the documentation
running cargo test --test bug
   Compiling example v0.1.0 (file:///Users/software-concepts/workspace/jeroen.knoops/rust-example)
    Finished dev [unoptimized + debuginfo] target(s) in 0.58 secs
     Running target/debug/deps/bug-6262d8198d8b39aa

running 1 test
test test_substract ... FAILED

failures:

---- test_substract stdout ----
	thread 'test_substract' panicked at 'assertion failed: `(left == right)`
  left: `16`,
 right: `6`', tests/bug.rs:6:5
note: Run with `RUST_BACKTRACE=1` for a backtrace.


failures:
    test_substract

test result: FAILED. 0 passed; 1 failed; 0 ignored; 0 measured; 0 filtered out

error: test failed, to rerun pass '--test bug'
abc4c40d4a06711bab5039a2896db3f67d8ddd0e is the first bad commit
commit abc4c40d4a06711bab5039a2896db3f67d8ddd0e
Author: Jeroen Knoops <jeroen.knoops@gmail.com>
Date:   Sun Aug 12 17:03:29 2018 +0200

    Adds function 'multiply' with a runnable example in the documentation

:040000 040000 27cde4ec60027b8faffb1e97f3cb42022e80187b 34e8c57493a1b137f34fe45bf5ec555888ad8c3b M	src
bisect run success
[I]  ~  workspace  jeroen.knoops  rust-example  ⚓ abc4c40  ❓  $  git log
commit abc4c40d4a06711bab5039a2896db3f67d8ddd0e (HEAD, refs/bisect/bad)
Author: Jeroen Knoops <jeroen.knoops@gmail.com>
Date:   Sun Aug 12 17:03:29 2018 +0200

    Adds function 'multiply' with a runnable example in the documentation

commit 2a5a0578f44883d360287fc771c9d1dd7cff4cd6 (refs/bisect/good-2a5a0578f44883d360287fc771c9d1dd7cff4cd6)
Author: Jeroen Knoops <jeroen.knoops@gmail.com>
Date:   Sun Aug 12 17:01:27 2018 +0200

    Adds readme.md

commit 3d75d3da596b4fced7c4e91b17c20b2b61d2c8c5
Author: Jeroen Knoops <jeroen.knoops@gmail.com>
Date:   Sun Aug 12 16:59:58 2018 +0200

    Adds travis-ci pipeline

commit 030b72500f08774b685c59c3e5ddd64afce432f1 (refs/bisect/good-030b72500f08774b685c59c3e5ddd64afce432f1)
Author: Jeroen Knoops <jeroen.knoops@gmail.com>
Date:   Sun Aug 12 16:58:49 2018 +0200

    Adds functions 'add' and 'substract'
```

Commit which introduced the bug:
<a href="https://github.com/JeroenKnoops/rust-example/commit/abc4c40d4a06711bab5039a2896db3f67d8ddd0e">
  https://github.com/JeroenKnoops/rust-example/commit/abc4c40d4a06711bab5039a2896db3f67d8ddd0e
</a>

<a href="#">
    <img src="{{ site.baseurl }}/assets/2019-03-11-git-bisect/git-bisect-gitx.png" alt="gitx">
</a>

## Results

When implementing `multiply`, I've accidentally broken the `substract` function.
Git bisect will also add refs so you can which commits have been tested.

The correct implementation would be:

```rust
pub fn substract(a: i32, b: i32) -> i32 {
    a - b
}
```

The test we've written to find the bug can be renamed and also added to prevent this from happening again.

## Conclusion

This was a very simple test / bug to find. By doing a `git blame` on the line, we would found the same
error, but this is not always the case.
Imagine a website which overtime became very slow. Try to create a test which measures the performance of a certain
page. This test should fail when the performance is below a certain threshold. This can be a complete end-to-end test.
Now you will find the exact place where the introduction of a small stupid javascript library caused a big performance
problem.

