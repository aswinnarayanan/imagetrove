#!/bin/bash
docker build -t aswinnarayanan/imagetrove .
docker run -it --network="host" aswinnarayanan/imagetrove
