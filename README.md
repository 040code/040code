# 040 Code blog

Run locally:
```
docker run -d --name blog -p 4000:4000 -w /srv/jekyll -v $(pwd):/srv/jekyll \
  jekyll/jekyll:3.5.2 /bin/bash -c  "bundle install && jekyll server -H 0.0.0.0 --watch"
```
