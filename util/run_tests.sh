#!/usr/bin/env bash

###################################################################
# Script Name : run_test.sh
# Description	: Will run the projects tests
# Args        : -
# Author      : Délio Amaral
# Email       : delio@cloudoki.com
###################################################################


# Run common code
. ./common.sh

# For each updated project go into it and run the test
for project in ${PROJECTS}; do
  if [ -n "$project" ]; then
    # Go into folder and run npm i
    (cd ../${ROOT_PROJECTS_FOLDER}/${project} && npm i)
    # Go into folder and run test
    (cd ../${ROOT_PROJECTS_FOLDER}/${project} && npm run test)
  fi
done