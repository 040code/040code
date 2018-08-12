---
layout:     post
title:      "Git Bisect"
subtitle:   "Find the bug-introducing-commit with Git Bisect"
date:       2018-08-13
authors:     [jeroen]
header-img: "assets/2018-08-13-git-bisect/vanmoll-brew.jpg"
tags:       [git]
---

https://github.com/JeroenKnoops/rust-example


Create test in `/tests/bug.rs`

```rust
extern crate example;
use example::*;

#[test]
fn test_substract() {
      assert_eq!(substract(8, 2), 6);
}
```

Run this test only.
```
cargo test --test bug
```

Test on master: https://asciinema.org/a/4q7AMN03KVoX9jSzZRlujuM69


Test on first commit: https://asciinema.org/a/BMe7Q3EfXfhyNlpVw8sI6c7yV

```
git bisect start
git bisect bad
git bisect good 030b72500f08774b685c59c3e5ddd64afce432f1
git bisect run cargo test --test bug
```

https://asciinema.org/a/o3LgoxXPp7WVQbhNMk628Lz4p

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
https://github.com/JeroenKnoops/rust-example/commit/abc4c40d4a06711bab5039a2896db3f67d8ddd0e
