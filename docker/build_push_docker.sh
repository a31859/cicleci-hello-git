rm .env
echo ${DOCKER_USER_PASS} | docker login --username ${DOCKER_USER_NAME} --password-stdin
HELLO_PACKAGE_VERSION=$(cat ../packages/hello/package.json | grep version | head -1 | awk -F ": " '{ print $2 }' | sed 's/[",]//g')
echo "HELLO_PACKAGE_VERSION=${HELLO_PACKAGE_VERSION}" >> .env
docker-compose config
docker-compose build
docker-compose push