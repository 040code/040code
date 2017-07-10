---
layout:     post
title:      "Visualising Bézier Curves Part II"
subtitle:   "Experimenting with ClojureScript"
date:       2017-07-08
author:     "Maarten Metz"
header-img: "img/HDP.JPG"
tags:       [clojure, clojurescript, bézier, functional, klipse, canvas]
---

In my [previous post](https://040code.github.io/2017/07/01/bezier-in-clojure/) I described how to visualise simple Bézier curves. I chose `Clojure` as implementation language. Unfortunately I had to ask you to jump through a couple of hoops in order to code along: installing leiningen, installing and configuring the lein-try plugin and maybe even installing the JVM.

This post will be easier for you - at least in terms of setup. You won't have to leave your browser and can experiment with `Clojure(Script)` right here on this page!

## NO Setup

In this post we're going to use the very useful [klipse plugin](https://github.com/viebel/klipse). Klipse is a client-side code evaluator pluggable on any web page. It can evaluate `Clojure`, `ClojureScript`, ruby, javascript, python, scheme, es2017, jsx, brainfuck, c++, reagent and probably much more languages in the near future. It's like [jsfiddle](https://jsfiddle.net) on steroids, right here in the 040code blog.

Let's start with a very simple Klipse demonstration. I'm going to `map` the `inc`(rement) function over the numbers 1, 2 and 3. The result will not surprise you:

<pre><code class="language-klipse">(map inc [1 2 3])</code></pre>

What might surprise you though, is that **you can change the code in the klipse evaluator** and see the results immediately in your browser. So for instance change `(map inc [1 2 3])` into `(map inc [41 999 2])` and be amazed. Or change it into something completely different like `(filter even? (range 10))`.

Defining functions and calling them? No problem:

<pre>
  <code class="language-klipse">
(defn factorial [n]
  (if (= 1 n)
    n
    (* n (factorial (- n 1)))))
    
(factorial 4)
  </code>
</pre>

Now call the factorial function with some other natural number (whole number > 0) and see the results.

For those of you who don't know `Clojure(Script)`, this function basically says:

- define a function named `factorial`
- let `n` be its argument
- if `n` equals 1, return `n`
- otherwise return the multiplication of `n` with the `factorial` of (n - 1)

Lisp in the browser. Embedded in this blog. No setup required. Excellent!

But hang on, better things will follow soon.

## Clojure is designed to be a hosted language

Why reinvent your own platform, your own runtime, your own garbage collector, your own ecosystem, when all you need is a decent language? `Clojure` is designed to be a hosted language. It runs on:

- [The JVM](https://www.clojure.org/about/jvm_hosted)
- [The CLR](https://www.clojure.org/about/clojureclr) 
- [Javascript engines](https://clojurescript.org)

`Clojurescript` - a compiler for `Clojure` that emits javascript - will be the tool we use in this blog to visualise Bézier curves. We are going to manipulate a html canvas right from a klipse plugin.

## Bézier in ClojureScript 

In my [previous post](https://040code.github.io/2017/07/01/bezier-in-clojure/) I tried to explain how (simple) Bézier curves 'work'. You might want to go there or scan the [Wikipedia page on Bézier curves](https://en.wikipedia.org/wiki/Bézier_curve) if you have no clue what I'm talking about. Otherwise, let's dive right in and try to play with Bézier curves directly on this page.

  <pre>
    <code class="language-klipse">
;; Get a grip on the html canvas element I inserted on this page
(def canvas (.getElementById js/document "canvas-2d"))
(def ctx    (.getContext canvas "2d"))


;; Draws a blue circle with radius `r` on the canvas on point [x y] 
(defn draw-point [x y]
  (let [r 5] ;; radius
    (set! (.-fillStyle ctx) "blue")
    (.beginPath ctx)
    (.arc ctx x y r 0 (* 2 Math/PI))
    (.fill ctx)))


;; Draws a red Bézier curve and its blue control points on the canvas
(defn draw-bezier-curve [[x1 y1] [x2 y2] [x3 y3]]
  ;; draw curve
  (set! (.-strokeStyle ctx) "red")
  (set! (.-lineWidth   ctx) 2)
  (.beginPath ctx)
  (.moveTo ctx x1 y1)
  (.quadraticCurveTo ctx x2 y2 x3 y3)
  (.stroke ctx)
  (.closePath ctx)
  ;; draw control points
  (draw-point x1 y1)
  (draw-point x2 y2)
  (draw-point x3 y3))


;; Center the *drawing* canvas within the *html* canvas and draw the curves
;;
;; Reason for centering: keep the coordinates simple AND 
;; see the complete shapes (not cropped at the edge of the html canvas)
;; make the ratio 1 to see what I mean with 'cropped at the edge'
;;
(let [wc (.-width canvas)  ;; width of *html* canvas
      hc (.-height canvas) ;; height of *html* canvas
      ratio 0.9            ;; ratio of *html* canvas to use as *drawing* canvas
      t  (/ (- 1 ratio) 2) ;; translation constant
      w  (* ratio wc)      ;; width of *drawing* canvas 
      h  (* ratio hc)      ;; height of *drawing* canvas
      x  (* 1/2 w)         ;; x val in the middle of 0 and w
      y  (* 1/2 h)]        ;; y val in the middle of 0 and h

  ;; clear *html* canvas
  (.clearRect ctx 0 0 wc hc)  

  ;; Center the *drawing* canvas in the *html* canvas
  (.save ctx)
  (.translate ctx (* t wc) (* t hc))

  ;; Draw a grey border around the *drawing* canvas
  (set! (.-lineWidth ctx) 1)
  (set! (.-strokeStyle ctx) "grey")
  (.strokeRect ctx 0 0 w h)

  ;; Draw main 'anchor' points
  ;; This is what I meant with 'simple coordinates':
  ;; (draw-point 0 0)
  ;; (draw-point x y)
  ;; (draw-point w h)

  ;; Increasing ascending curve
  (draw-bezier-curve [0 h] [w h] [w 0])
  
  ;; Swoosh
  ;; (draw-bezier-curve [0 y] [0 h] [w 0])

  ;; normal curve
  ;; (draw-bezier-curve [0 h] [x 0] [w h])

  ;; my pulse after a useless meeting
  ;; (draw-bezier-curve [0 y] [x y] [w y])

  (.restore ctx))
    </code>
  </pre>

<canvas id="canvas-2d" width="600" height="600"></canvas>

<script src="http://app.klipse.tech/plugin/js/klipse_plugin.js?"></script>

Before reading further you might want to experiment a bit by (un)commenting code and seeing the results. (Un)comment the different Bézier curves and different control points in the Klipse evaluator and see what happens.

## Explanation

Scanning the code quickly without going into detail, this is what happens:

- Get a grip on the html canvas element
- Define functions to:
	- Draw (control) points
	- Draw Bézier curves with 3 control points
- Draw the actual curves and points

Since `Clojure` is a hosted language, it must be able to access its host platform and libraries. `Clojure` and `ClojureScript` have good [interop](https://clojure.org/reference/java_interop) [documentation](http://cljs.github.io/api/syntax/#dot) so I won't go into detail here, but we're basically using these forms in this blog:

- `js/document`       => the global document object
- `(.beginPath ctx)`  => `ctx.beginPath()`
- `Math/PI`           => 3.141592653589793
- `(.-lineWidth ctx)` => `ctx.lineWidth`

The last form is used for instance in `(set! (.-lineWidth ctx) 1)` and translates to `ctx.lineWidth = 1`. The more general syntax is `(set! var-symbol expr)`.

The second form `(.beginPath ctx)` can also have arguments. The general syntax is `(.instanceMember instance args*)` in that case. 

Other than that it's basic `Clojure` and [HTML Canvas functionality](https://www.w3schools.com/tags/ref_canvas.asp)


## Conclusion

Thanks to the klipse plugin and a bit of preparation from my side, you can now play around with Bézier Curves in `ClojureScript` directly in this blog. I do realise this post is probably not a compelling case for using `ClojureScript`:

- Javascript "in the small" is not really the place where `ClojureScript` shines, especially when the largest part of that small program is javascript interop
- `ClojureScript` fits large browser applications better, where you need sane state management, immutable datastructures, lazy sequences, and a fast,  stable and robust language

I'm not interested in 'religious' discussions about technology A versus technology B. `Clojure` and `ClojureScript` are THE sane way forward for me, in my context. I hope to share the fun I'm experiencing with it. Goethe said it best:

> It is always better to say right out what you think without trying to prove anything much: for all our proofs are only variations of our opinions, and the contrary-minded listen neither to one nor the other.

But with all this talk about language, we're almost forgetting what it's all about: building useful stuff and having a great time doing it.

I hope you enjoyed experimenting with Bézier curves. The [Klipse Blog](http://blog.klipse.tech) has several great examples of using Klipse for 'interactive programming', for instance [to write data driven documents](http://blog.klipse.tech/data/2017/03/17/data-driven-documents-google-charts.html).

Thanks Niek for sharing the 040code repo with me. Please share your comments, suggestions and thoughts about this blog post on [twitter.com/mmz_](https://twitter.com/mmz_). Thanks for reading and Happy Coding!

## Links

- [Bézier in Clojure - Part I](https://040code.github.io/2017/07/01/bezier-in-clojure/)
- [Klipse plugin](https://github.com/viebel/klipse)
- [Klipse Blog](http://blog.klipse.tech)
- [Klipse App in the browser](http://app.klipse.tech)
- [Explanation about the Klipse app](http://blog.klipse.tech/clojure/2016/03/17/klipse.html)
- [Using Klipse for generating data driven charts](http://blog.klipse.tech/data/2017/03/17/data-driven-documents-google-charts.html)
- [JSfiddle](https://jsfiddle.net)
- [Javascript interop](http://cljs.github.io/api/syntax/#dot)
- [Java interop](https://clojure.org/reference/java_interop)
- [HTML Canvas functionality](https://www.w3schools.com/tags/ref_canvas.asp)