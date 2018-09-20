#!/bin/bash

docker run -d --rm --name blog -p 4000:4000 -w /srv/jekyll -v $(pwd):/srv/jekyll jekyll/jekyll:3.5.2 /bin/bash -c "bundle install && jekyll server -H 0.0.0.0 --watch"
echo "Waiting blog to launch on 4080..."

waitport() {
  set -e
  while ! curl --output /dev/null --silent --head --fail http://localhost:$1; do sleep 1 && echo -n .; done;
  set +e
}

waitport 4000

echo "blog launched"
echo "Have fun on http://localhost:4000"
