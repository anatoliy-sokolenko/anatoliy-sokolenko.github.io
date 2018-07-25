#!/bin/sh

docker run --rm -v $PWD:/srv/jekyll -v $PWD/.bundle:/usr/local/bundle -p4000:4000 jekyll/jekyll jekyll serve --incremental