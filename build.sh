#!/bin/bash

docker build -t imagetrove/mytardis -f Dockerfile .
docker build -t imagetrove/staging -f Dockerfile-staging .
