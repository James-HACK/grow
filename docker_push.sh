#!/bin/bash
set -e

# Also needs to be updated in Dockerfile when changed.
GROW_VERSION=`cat grow/VERSION`

if [ "$1" == "gcr.io" ]; then
  echo "Building and Pushing Grow $GROW_VERSION to gcr.io"
  echo "To build and push to Docker run 'docker_push.sh'"
else
  echo "Building and Pushing Grow $GROW_VERSION to Docker Hub"
  echo "To build and push to gcr.io run 'docker_push.sh gcr.io'"
fi

# Ubuntu Base.
docker build --no-cache --build-arg grow_version=$GROW_VERSION \
  -t grow/base:$GROW_VERSION -t grow/base:latest \
  -t gcr.io/grow-prod/base:$GROW_VERSION -t gcr.io/grow-prod/base:latest \
  -t grow/baseimage:$GROW_VERSION -t grow/baseimage:latest .

docker run --rm=true --workdir=/tmp -i grow/base:$GROW_VERSION  \
  bash -c "git clone https://github.com/grow/grow.io.git && cd grow.io/ && grow install && grow build"

# Google cloud registry.
if [ "$1" == "gcr.io" ]; then
  docker push gcr.io/grow-prod/base:$GROW_VERSION
  docker push gcr.io/grow-prod/base:latest
else
  docker push grow/base:$GROW_VERSION
  docker push grow/base:latest

  # Legacy docker image support.
  docker push grow/baseimage:$GROW_VERSION
  docker push grow/baseimage:latest
fi

# Ubuntu Command.
docker build --no-cache --build-arg grow_version=$GROW_VERSION \
  -t grow/grow:$GROW_VERSION -t grow/grow:latest \
  -t gcr.io/grow-prod/grow:$GROW_VERSION -t gcr.io/grow-prod/grow:latest \
  -f Dockerfile.exec .

docker run grow/grow:$GROW_VERSION --version

# Google cloud registry.
if [ "$1" == "gcr.io" ]; then
  docker push gcr.io/grow-prod/grow:$GROW_VERSION
  docker push gcr.io/grow-prod/grow:latest
else
  docker push grow/grow:$GROW_VERSION
  docker push grow/grow:latest
fi

# Alpine Base.
docker build --no-cache --build-arg grow_version=$GROW_VERSION \
  -t grow/base:$GROW_VERSION-alpine -t grow/base:alpine-latest \
  -t gcr.io/grow-prod/base:$GROW_VERSION-alpine -t gcr.io/grow-prod/base:alpine-latest \
  -f Dockerfile.alpine .

docker run --rm=true --workdir=/tmp -i grow/base:$GROW_VERSION-alpine  \
  bash -c "git clone https://github.com/grow/grow.io.git && cd grow.io/ && grow install && grow build"

# Google cloud registry.
if [ "$1" == "gcr.io" ]; then
  docker push gcr.io/grow-prod/base:$GROW_VERSION-alpine
  docker push gcr.io/grow-prod/base:alpine-latest
else
  docker push grow/base:$GROW_VERSION-alpine
  docker push grow/base:alpine-latest
fi

# Alpine Command.
docker build --no-cache --build-arg grow_version=$GROW_VERSION \
  -t grow/grow:$GROW_VERSION-alpine -t grow/grow:alpine-latest \
  -t gcr.io/grow-prod/grow:$GROW_VERSION-alpine -t gcr.io/grow-prod/grow:alpine-latest \
  -f Dockerfile.exec .

docker run grow/grow:$GROW_VERSION-alpine --version


# Google cloud registry.
if [ "$1" == "gcr.io" ]; then
  docker push gcr.io/grow-prod/grow:$GROW_VERSION-alpine
  docker push gcr.io/grow-prod/grow:alpine-latest
else
  docker push grow/grow:$GROW_VERSION-alpine
  docker push grow/grow:alpine-latest
fi
