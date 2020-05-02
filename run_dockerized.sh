#!/bin/bash

docker build --tag=drman/gradle .

#docker run --rm -it -v $PWD:/usr/src/app -v $HOME/.gradle:/root/.gradle drman/gradle test

docker run \
  -it \
  -v $PWD:/usr/src/app \
  -v $HOME/.gradle:/root/.gradle \
  --entrypoint=/bin/bash \
  drman/gradle

 