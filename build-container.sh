#!/bin/bash

(
  cd logstash-output-logio
  if [ ! -f logstash-output-logio.tar.gz ]; then
    make
  fi
)

docker build \
  -t logio \
  .
