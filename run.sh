#!/bin/bash
docker build -t imagetrove/imagetrove .
docker run -it --network="host" imagetrove/imagetrove
