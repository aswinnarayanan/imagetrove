#!/bin/bash

bash build.sh
docker-compose down
docker-compose up -d --build
docker-compose logs -f
