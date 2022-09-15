#!/bin/bash

docker version

# Set up docker environment for mongodb backend
docker network create fabmedical
docker container run --name mongo --net fabmedical -p 27017:27017 -d mongo:4.0

# Seed the mongo db
cd ~/Fabmedical/content-init
npm ci
nodejs server.js

echo "Build agent setup complete!"
