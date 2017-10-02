# 040 Code blog

# Run locally:

```
docker run -d --name blog -p 4000:4000 -w /srv/jekyll -v $(pwd):/srv/jekyll \
  jekyll/jekyll:3.5.2 /bin/bash -c  "bundle install && jekyll server -H 0.0.0.0 --watch"
```

or use the start script:
``` fish
source bin/start.fish
```

# Branches

Everything in `source` branch is pushed automatically to `master`.
From there it will be put online automatically.

[See travis-ci](https://travis-ci.org/040code/040code.github.io) to
understand the `jekyll rake` task.`

