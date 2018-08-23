#!/bin/bash
docker build -t aswinnarayanan/imagetrove .
docker run -it -p 8000:8000 --network="host" aswinnarayanan/imagetrove
