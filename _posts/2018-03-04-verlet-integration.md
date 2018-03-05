---
layout:          post
title:           "Verlet Integration"
subtitle:        "Physics Simulation in Clojure"
authors:         [maarten]
header-img:      "img/ehv-noord.jpg"
tags:            [clojure]
published:       true
enable_klipsejs: 1
---

## Introduction

In this post we're going to dive into physics simulation with Clojure. The
ideas in this post were mostly inspired by [this paper by Thomas
Jakobsen](http://graphics.cs.cmu.edu/nsp/course/15-869/2006/papers/jakobsen.htm).

My motivations for working on this toy project were:

- Experimenting with a very mutable domain in a language with immutability at
  its core
- Having some fun by making a lot happen on screen with little code
- Developing with emacs & [cider](https://github.com/clojure-emacs/cider) (The
  `C`lojure `I`nteractive `D`evelopment `E`nvironment that `R`ocks)

The result can be seen in [this short video](add link to youtube). The source
code can be found [here](https://github.com/mmzsource/verlet).

## One main- to bind them all

This code uses the [Quil library](https://github.com/quil/quil) to render points
and lines. In the `main-` function, the `sketch` macro from the Quil library is
used to bind the physics domain to the UI.

```clojure
(defn -main []
  (quil/sketch
    :host           -main
    :title          "Verlet Integration"
    :size           [width height]
    :setup          setup
    :update         update-state
    :draw           draw
    :key-pressed    key-pressed
    :mouse-pressed  mouse-pressed
    :mouse-dragged  mouse-dragged
    :mouse-released mouse-released
    :features       [:exit-on-close]
    :middleware     [quil-mw/fun-mode]))
```

The sketch macro basically asks the developer to configure which 'handler
functions' it should call when certain events occur. For instance:

- a key is pressed -> call `key-pressed`
- the mouse is pressed -> call `mouse-press`
- the state of your program has to be updated -> call `update-state`
- it's time to draw the new state -> call `draw`
- etc.

Because I configured Quil to run in functional mode `(quil-mw/fun-mode)`, Quil:

- Uses the return value from the `:setup` function as the initial state
- Passes the state to each handler function to update the state
- Additionally passes a keyboard- and mouse event argument to keyboard - and
  mouse handler functions.

The handler function signatures therefore look like this:

```clojure
(defn draw          [state]       ...)
(defn update-state  [state]       ...)
(defn key-pressed   [state event] ...)
(defn mouse-pressed [state event] ...)
```

## Physics Simulation

As you might have seen in [the video](link to video), this physics simulation
deals with 'points', 'sticks' connecting points and combinations of those. The
points are the things that seem to have direction and speed, are influenced by
gravity and lose speed because of friction or because of bouncing against world
borders. The sticks try to keep their 2 points apart according to the configured
stick length. The simulation loop boils down to:

- Update points
- Apply stick constraints
- Apply world constraints

In code:

```clojure
(defn update-state
  [state]
  (->> state
       (update-points)
       (apply-stick-constraints)
       (apply-world-constraints)))
```

This code can be read like this: 'with `state`, first `update-points`, then
`apply-stick-constraints`, and finally `apply-world-constrains`'. Without using
the thread last macro `->>`, the code would look like this:

```clojure
(defn update-state [state]
  (apply-world-constraints (apply-stick-constraints (update-points state))))
```

I guess it's a matter of taste which one you prefer.

### Points

`Points` are the main abstraction in this code. I decided to use a record to name
them:

```clojure
(defrecord Point [x y oldx oldy pinned])
```

A `Point` stores its current coordinates and the coordinates it had in the
previous world state. On top of that it has a `pinned` property which indicates
if a `Point` is pinned in space and - as a result - stays on the same
coordinate.

The `update-point` function calculates the velocity of the `Point` and adds some
gravity in the mix:

```clojure
(defn update-point
  [{:keys [x y oldx oldy pinned] :as point}]
  (if pinned
    point
    (let [vx (velocity x oldx)
          vy (velocity y oldy)]
      (->Point (+ x vx) (+ y vy gravity) x y pinned))))
```

Reading superficially, this code says: if the point is pinned then return the
same point. Otherwise, calculate it's velocity (based on the current and
previous x & y coordinates), add some gravity in the y direction and return the
newly calculated point.

The function uses
[destructuring](https://gist.github.com/john2x/e1dca953548bfdfb9844) to name all
the arguments of the incoming `Point`. With destructuring, you can bind the
values in a data structure without explicitly querying the data structure. So
instead of getting each and every value out of `point` and binding it to a 'new'
name:

```clojure
(let [x      (:x      point)
      y      (:y      point)
      oldx   (:oldx   point)
      oldy   (:oldy   point)
      pinned (:pinned point)]
  ...)
```

you can very effectively tell the function that it will receive a map `{}` with
keys `x y oldx oldy pinned` and that this function should have those variables
available under the same name:

```clojure
[{:keys [x y oldx oldy pinned] :as point}]
```

The code in my repository has some additional type hints, because I wanted the
simulation to run smooth on my laptop and wanted to learn a bit more about type
hinting and compiler optimizations.

And that's it with regard to `Points`. In a couple of lines of code `Points` are
already moving and reacting to gravity in the simulation.

### World constraints

It's time for points to meet the harsh reality of life. Walls are harder than
points and points should bounce off of them:

```clojure
(defn hit-floor?       [y] (> y height))
(defn hit-ceiling?     [y] (< y 0))
(defn hit-left-wall?   [x] (< x 0))
(defn hit-right-wall?  [x] (> x width))


(defn apply-world-constraint
  [{:keys [x y oldx oldy pinned] :as point}]
  (let [vxb (* (velocity x oldx) bounce)
        vyb (* (velocity y oldy) bounce)]
    (cond
      (hit-floor?      y) (let [miry (+ height height (- oldy))]
                             (->Point  (+ oldx vxb) (- miry vyb) oldx miry pinned))
      (hit-ceiling?    y) (let [miry (- oldy)]
                             (->Point (+ oldx vxb) (+ miry (- vyb)) oldx miry pinned))
      (hit-left-wall?  x) (let [mirx (- oldx)]
                             (->Point (+ mirx (- vxb)) (+ oldy vyb) mirx oldy pinned))
      (hit-right-wall? x) (let [mirx (+ width width (- oldx))]
                             (->Point (- mirx vxb) (+ oldy vyb) mirx oldy pinned))
      ;; else: free movement
      :else point)))
```

To explain what happens here, a picture might help.

<a href="#">
    <img src="{{ site.baseurl }}/img/verlet-physics/world-constraints.png"
    alt="apply world constraints diagram">
</a>

Imagine a point moved from A to B in the last point update. This means a point
record is persisted with its `x` and `y` being the coordinates of B and `oldx`
and `oldy` being the coordinates of A. If a wall line crossed the imaginary line
A-B, the point history should be rewritten. In essence, line A-B is mirrored in
the wall it hits, giving rise to another imaginary line C-D where C mirrors A
and D mirrors B. The `miry` (mirror-y) and `mirx` (mirror-x) vars in the code
contain C coordinates mirroring A coordinates.

The simulation will take a little velocity loss into account. Therefore, D' is
calculated by using the x and y velocities (vx and vy) multiplied by a bounce
factor (leading to the `vxb` and `vyb` variables in the code).

When the world state is drawn, the point will fly off in exactly the right
direction. Additionally, because of the history rewrite, subsequent `Point`
updates will keep moving the point in the right direction.

The picture shows the situation when hitting the ceiling. Hitting the floor and
the walls works similar. And that's all the math and code you need to simulate
`Points` moving in a bounded space. Now let's add sticks to the simulation.

### Stick constraints

Not only walls are restricting `Points` from free movement; sticks also
constrain them. A stick connects 2 points and has a configured length. The
goal of the stick constraint is to move the points at the end of the stick
closer to the configured length of the stick.

<a href="#">
    <img src="{{ site.baseurl }}/img/verlet-physics/stick-constraints.png"
    alt="apply stick constraints diagram">
</a>

So instead of trying to calculate the solution that satisfies all constraints at
once, this code simply looks at one stick at a time and 'solves' the constraint
problem by repeatedly solving stick constraints in isolation.

```clojure
(defn apply-stick-constraint
  [{length :length :as stick}
   {p0x :x p0y :y oldp0x :oldx oldp0y :oldy pinp0 :pinned :as p0}
   {p1x :x p1y :y oldp1x :oldx oldp1y :oldy pinp1 :pinned :as p1}]
  (let [{:keys [dx dy distance]} (distance-map p0 p1)
        difference (- length distance)
        percentage (/ (/ difference distance) 2)
        offsetX    (* dx percentage)
        offsetY    (* dy percentage)
        p0-new     (->Point (- p0x offsetX) (- p0y offsetY) oldp0x oldp0y pinp0)
        p1-new     (->Point (+ p1x offsetX) (+ p1y offsetY) oldp1x oldp1y pinp1)]
    [(if pinp0 p0 p0-new) (if pinp1 p1 p1-new)]))
```

The stick-constraint function takes 3 arguments which are heavily destructured:
a stick, and 2 points (p0 and p1). First it calculates the distance between the
points. Next it calculates the difference between the stick length and the point
distance.

<script src="https://storage.googleapis.com/app.klipse.tech/plugin/js/klipse_plugin.js?"></script>

## Conclusion

As always, it was a pleasure working with Clojure. It turns out to be easy to
work in a very mutable domain with mostly pure functions.

I'm glad I decided to 'bite the bullet' and learn Emacs and cider. Apart from
writing this blog in Emacs, I now do all my clojure experiments in Emacs, not to
mention most of my writing and (project)planning.

I'd like to thank Michiel Borkent a.k.a.
[@borkdude](https://twitter.com/borkdude) for reviewing an earlier version of
the verlet code and giving me very helpful feedback. Faults and not-so-idiomatic
Clojure code remaining are my own.

Please share your comments, suggestions and thoughts about this blog post on
[twitter.com/mmz_](https://twitter.com/mmz_). Thanks for reading and Happy
Coding!

## Links

- [Verlet integration
  paper](http://graphics.cs.cmu.edu/nsp/course/15-869/2006/papers/jakobsen.htm)
- [My verlet integration code in clojure](https://github.com/mmzsource/verlet)
- [Quil library](https://github.com/quil/quil)
- [Cider plugin](https://github.com/clojure-emacs/cider)
- [Klipse plugin](https://github.com/viebel/klipse)

## Sketch

You can try the difference yourself by changing this code:

<pre>
  <code class="language-klipse">
(->> (range)
     (filter even?)
	 (take 10))
  </code>
</pre>

to this code `(take 10 (filter odd? (range)))` and changing back and forth
(undoing your change or refreshing the browser will return the original code)
