#!/bin/bash
cd mytardis
docker-compose -f docker-build.yml run builder
docker build -f Dockerfile-run -t mytardis/mytardis-run .
