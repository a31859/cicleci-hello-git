#!/usr/bin/env bash

###################################################################
# Script Name : build_push_docker.sh
# Description	: Will create the necessary environment variables, \
#               identify the services to build (monorepo) and call docker compose to \
#               build and push for those services
# Args        : -
# Author      : Délio Amaral
# Email       : delio@cloudoki.com
###################################################################

# Function to convert yaml to json with ruby
function yaml2json()
{
  ruby -ryaml -rjson -e 'puts JSON.pretty_generate(YAML.load(ARGF))' $*
}

# Remove .env if exits
rm .env

# Login into docker hub
echo ${DOCKER_USER_PASS} | docker login --username ${DOCKER_USER_NAME} --password-stdin

# Create .env
touch .env

# Set docker repo
DOCKER_REPO="delioamaral/circleci-test"

# Set the root directory of projects folder
ROOT_PROJECTS_FOLDER="packages"

# Set the list of projects
PROJECTS_LIST=$(ls -d ../${ROOT_PROJECTS_FOLDER}/*/ | cut -f3 -d/)
echo $PROJECTS_LIST

# Write envs to .env
echo "DOCKER_REPO=${DOCKER_REPO}" >> .env

# Create env vars with the version for each package and write to .env
for project in ${PROJECTS_LIST}; do
  PROJECT_PACKAGE_VERSION="develop"
  if [ "${CIRCLE_BRANCH}" != "develop" ]; then
    PROJECT_PACKAGE_VERSION=$(cat ../${ROOT_PROJECTS_FOLDER}/${project}/package.json | grep version | head -1 | awk -F ": " '{ print $2 }' | sed 's/[",]//g')
  fi
  echo "Creating the var for $(echo $project | tr '[:lower:]' '[:upper:]' | tr '-' '_')_PACKAGE_TAG"
  echo "$(echo $project | tr '[:lower:]' '[:upper:]' | tr '-' '_')_PACKAGE_TAG=${project}-${PROJECT_PACKAGE_VERSION}" >> .env
done

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
# Filter result and only list the project folders that where updated $COMMITS
PROJECTS=$(git diff --name-only origin/master | grep "${ROOT_PROJECTS_FOLDER}" | cut -d/ -f2 | sort -u)
echo -e "Modified directories:\n`echo ${PROJECTS}`\n"

# Get the projects folder name to build
# Parse the ymal to json
PARSED_YAML=$(cat docker-compose.yaml | yaml2json)
# Convert the project list to an array
PROJECTS_AS_ARRAY=($(echo ${PROJECTS_LIST}))
for project in ${PROJECTS}; do
  # Remove the project from the array if exist
  CLEANED_PROJECTS_ARRAY=(${PROJECTS_AS_ARRAY[@]/#$project})

  # Compare the arrays sizes to see if theres a match (different sizes is a match)
  if [[ "${#PROJECTS_AS_ARRAY[@]}" != "${#CLEANED_PROJECTS_ARRAY[@]}" ]]; then
    SERVICE_NAME=$(echo $PARSED_YAML | jq -r ".services | to_entries[] | select (.value.build == \"../${ROOT_PROJECTS_FOLDER}/${project}\") | .key")
    echo "Will build [folder, service] -> [$project, $SERVICE_NAME]"
    DOCKER_SERVICES="$DOCKER_SERVICES $SERVICE_NAME"
  fi
done

echo "Services to build: $DOCKER_SERVICES"

# Build and push to docker registry
docker-compose config
# docker-compose build $DOCKER_SERVICES
# docker-compose push $DOCKER_SERVICES

# Logout from docker
# docker logout
