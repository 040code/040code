---
layout:     post
title:      "Visualising Bézier Curves"
subtitle:   "Experimenting with Clojure"
date:       2017-06-26
author:     "Maarten Metz"
header-img: "img/htc.jpg"
tags:       [clojure, bézier, functional, incanter]
---

For reasons I might explain in another post, I was searching for [Bézier curves on wikipedia](https://en.wikipedia.org/wiki/Bézier_curve) the other day. Especially the paragraph on "Constructing Bézier curves" made me understand intuitively how these curves are constructed. I wondered if `Clojure` could help me easily visualise some of these curves so I fired up a [REPL](https://en.wikipedia.org/wiki/Read–eval–print_loop) (Read-Eval-Print-Loop) to investigate.

## Setup

I assume you have a working [leiningen](https://leiningen.org) setup with the [lein-try plugin](https://github.com/rkneufeld/lein-try) installed. 

- Leiningen will help you get started with clojure right away from your shell
- Lein-try enables you to spin up a repl and try a library without any hassle.

Let's first start a repl, and specify the library we want to try:

```bash
lein try incanter "1.5.7"
```

[Incanter](http://incanter.org) is a clojure-based, R-like platform for statistical computing and graphics. I use it to visualise the Bézier curves.

Since the repl is already fired up, let's immediately require the dependencies we'll need:

```clojure
(require '[incanter.core   :as incanter])
(require '[incanter.charts :as charts])
```

Nothing fancy going on here. Simply 'import' statements the `clojure` way.

## Helper function

I decided to hand-roll my own `pow` function:

```clojure
(defn pow [base exponent]
  (reduce *' (repeat exponent base)))
```

This function basically says:

- Define a function named `pow`
- it takes a `base` and an `exponent` as arguments
- it's going to `repeat` the base `exponent` times
- and reduce it with the `*'` multiply function

I'm using the `*'` multiply function instead of the normal `*` function, because according to the docs `*'` 'supports arbitrary precision'. You can see for yourself by typing `(doc *')` in your repl, or study the code: `(source *')`

## Bézier

Bézier functions work with control points. The minimum number of control points is 2 and Bézier curves with 2 control points are straight lines.

For the moment I only need Bézier curves with 3 control points: a start point, an end point and one point controlling the curve of the line between start and end.

Quoting the [Wikipedia page](https://en.wikipedia.org/wiki/Bézier_curve): "A quadratic Bézier curve is the path traced by the function B(t), given points P0, P1, and P2":

`B(t) = ((1-t)^2)P0 + 2(1-t)tP1 + (t^2)P2` for 0 <= t <= 1

So given 3 points (P0, P1 and P2) I should be able to describe the curve with this math function. The only thing this resulting `B(t)` function needs is the moment `t` and it will calculate the X or Y coördinate at that particular moment.

Let's convert the math function to clojure:

```clojure
(defn bezier-3 [p0 p1 p2]
  (fn [t]
    (+ 
      (* (pow (- 1 t) 2) p0)
      (* 2 (- 1 t) t     p1)
      (* (pow t 2)       p2))))
```

As you can see, you'll have to translate the infix notation to clojure's prefix notation, but the advantage is there are no precedence rules to remember anymore. Just lists where the first element is a function and only brackets are used to put them into context. (If you can't live with that: you can also feed incanter with [infix notation](https://data-sorcery.org/2010/05/14/infix-math/))

This function basically states:

- Define a function named `bezier-3`
- it takes 3 arguments
- it returns an anonymous function

This anonymous function

- takes `t` as an argument
- has `p0`, `p1` and `p2` already 'injected'
- applies the Bézier math function

Excellent. Let's try it:

```clojure
(def test-b3 (bezier-3 1 1 0))

(test-b3 0)
=> 1
```

Here I'm defining a variable `test-b3` which holds the anonymous function returned by the `bezier-3` function call. The 3 points are either all x or all y coordinates of the points P0, P1 and P2.

With the `(test-b3 0)` function call I'm calling the anonymous function `(fn [t] ...)` with a `t` value of `0`. This nicely returns an answer (and doesn't blow the stack or throw a NullPointerException or anything). 

So now let's map this function over a range of t's `[0 0.25 0.5 0.75 1]`:

```clojure
(map test-b3 [0 0.25 0.5 0.75 1])
=> (1 0.9375 0.75 0.4375 0)
``` 

Instead of typing these t's to `map` over, we could also use the range function:

```clojure
(range 0 10)
=> (0 1 2 3 4 5 6 7 8 9)

(range 0 10 2)
=> (0 2 4 6 8)
```

As you can see, range allows you to specify a start (inclusive), an end (exclusive) and a step size (optional).

```clojure
(map test-b3 (range 0 1 0.1))
=> (1 0.9900000000000001 0.9600000000000002 0.9099999999999999 0.84 0.75 0.64 0.51 0.3600000000000001 0.19000000000000014 2.220446049250313E-16)
```

Although a certain curve is already visible in these numbers, now might be the right time to start visualising.

## Visualise

Let's be brave and go right to the essence:

```clojure
(defn view-bezier-plot [[x1 y1] [x2 y2] [x3 y3]]
  (let [b3x (bezier-3 x1 x2 x3)
        xs (map b3x (range 0 1.0 0.01))
        b3y (bezier-3 y1 y2 y3)
        ys (map b3y (range 0 1.0 0.01))
        raw-dataset (incanter/conj-cols xs ys)
        dataset (incanter/col-names raw-dataset [:x :y])
        xy-plot (charts/xy-plot :x :y :points true :data dataset)]
    (incanter/view xy-plot)))
```

The `let` form is clojure's way to define local variables. So `b3x`, `xs`, `b3y`, etc. can be seen as local variables with their values specified after their declaration.

This function basically states:

- Define a function named `view-bezier-plot`
- it takes 3 arguments which are destructured in their 2D coordinates.
- it declares some local variables
	- `b3x` takes all x coordinates of the 3 points
	- `b3y` takes the y coordinates
	- `xs` are the all x values resulting from calling the `b3x` anonymous function with all the range values.
	- what the `ys` are is left as an assignment for the curious reader
	- incanter can work with columns similarly to spreadsheets. `raw-dataset` is an incanter dataset where 2 columns are `conj[oined]`.
	- Default, these columns are called `col-0` and `col-1` respectively, so in `dataset` these are renamed to `:x` and `:y`
	- xy-plot contains an incanter chart where `dataset` provides the data, the x-axis - and y-axis values are found in columns `:x` and `:y` respectively and I want to see the points.
- and eventually returns an `xy-plot`

Show it!

```clojure
;; Steep slope
;; Increasing ascending:
(view-bezier-plot [0 0] [1 0] [1 1])
(view-bezier-plot [0 0] [0.75 0.25] [1 1])
;; Lineair
(view-bezier-plot [0 0] [0.5 0.5] [1 1])
;; Decreasing ascending:
(view-bezier-plot [0 0] [0 1] [1 1])
(view-bezier-plot [0 0] [0.25 0.75] [1 1])

;; Medium slope
;; Increasing ascending
(view-bezier-plot [0 0.25] [0.375 0.75] [1 0.75])
;; Lineair
(view-bezier-plot [0 0.25] [0.5   0.5]  [1 0.75])
;; Decreasing ascending
(view-bezier-plot [0 0.25] [0.625 0.25] [1 0.75])

;; No slope
(view-bezier-plot [0 0.5] [0.5 0.5] [1 0.5])
```

## Conclusion

In a relatively short session I was able to get a better understanding of (3 point) Bézier curves. Although the blogpost is long, not much code or time was needed to create the curves:

```clojure
(require '[incanter.core   :as incanter])
(require '[incanter.charts :as charts])


(defn pow [base exponent]
  (reduce *' (repeat exponent base)))


(defn bezier-3 [p0 p1 p2]
  (fn [t]
    (+ 
      (* (pow (- 1 t) 2) p0)
      (* 2 (- 1 t) t     p1)
      (* (pow t 2)       p2))))


(defn view-bezier-plot [[x1 y1] [x2 y2] [x3 y3]]
  (let [b3x (bezier-3 x1 x2 x3)
        xs (map b3x (range 0 1.0 0.01))
        b3y (bezier-3 y1 y2 y3)
        ys (map b3y (range 0 1.0 0.01))
        raw-dataset (incanter/conj-cols xs ys)
        dataset (incanter/col-names raw-dataset [:x :y])
        xy-plot (charts/xy-plot :x :y :points true :data dataset)]
    (incanter/view xy-plot)))
```

Happy coding!