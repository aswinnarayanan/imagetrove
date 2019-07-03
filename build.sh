#!/bin/bash

docker build --network=host -t imagetrove/mytardis -f Dockerfile .
docker build --network=host -t imagetrove/staging -f Dockerfile-staging .
