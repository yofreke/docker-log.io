#!/bin/bash

docker run -d \
  -p 28777:28777 \
  -p 28778:28778 \
  -p 5514:5514 \
  -name logio \
  logio
