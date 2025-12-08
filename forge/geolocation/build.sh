#!/bin/bash

docker buildx build --no-cache --progress=plain --platform linux/amd64 --tag honeok/geolocation .
docker run -d --name geolocation -p 8080:8080 honeok/geolocation

# docker buildx build --no-cache --progress=plain --platform linux/amd64,linux/arm64 --tag honeok/geolocation:v1.0.0 --tag honeok/geolocation:latest --push .
