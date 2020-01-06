#!/usr/bin/env bash

# remove .env if exits
rm .env

# login into docker hub
echo ${DOCKER_USER_PASS} | docker login --username ${DOCKER_USER_NAME} --password-stdin

# create .env
touch .env

# docker repo
DOCKER_REPO="delioamaral/circleci-test"

# create env vars with the version for each package
HELLO_PACKAGE_VERSION="develop"
HELLO_2_PACKAGE_VERSION="develop"

if [ "${CIRCLE_BRANCH}" != "develop" ]; then
  HELLO_PACKAGE_VERSION=$(cat ../packages/hello/package.json | grep version | head -1 | awk -F ": " '{ print $2 }' | sed 's/[",]//g')
  HELLO_2_PACKAGE_VERSION=$(cat ../packages/hello2/package.json | grep version | head -1 | awk -F ": " '{ print $2 }' | sed 's/[",]//g')
fi

# write envs to .env
echo "HELLO_PACKAGE_TAG=hello-${HELLO_PACKAGE_VERSION}" >> .env
echo "HELLO_2_PACKAGE_TAG=hello2-${HELLO_2_PACKAGE_VERSION}" >> .env

# Identify modified directories

## Get latest succesful build/commit
LAST_SUCCESSFUL_BUILD_URL="https://circleci.com/api/v1.1/project/github/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME/tree/$CIRCLE_BRANCH?filter=completed&limit=1"
LAST_SUCCESSFUL_COMMIT=`curl -Ss -u "$CIRCLE_TOKEN:" $LAST_SUCCESSFUL_BUILD_URL | jq -r '.[0]["vcs_revision"]'`

## First commit in a branch
if [[ ${LAST_SUCCESSFUL_COMMIT} == "null" ]]; then
  COMMITS="origin/${CIRCLE_BRANCH}"
else
  COMMITS="${CIRCLE_SHA1}..${LAST_SUCCESSFUL_COMMIT}"
fi
git diff --name-only $COMMITS | cut -d/ -f1 | sort -u > projects
echo -e "Modified directories:\n`cat projects`\n"

# build and push to docker registry
docker-compose config
# docker-compose build
# docker-compose push
