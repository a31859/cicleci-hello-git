FROM node:12.13.1-alpine

WORKDIR /hello

RUN apk update
RUN apk add --no-cache make gcc g++ python curl

COPY . .

RUN rm -rf node_modules
RUN npm install -g node-gyp
RUN npm i


EXPOSE 3000

ARG IMAGE_TAG
LABEL IMAGE_TAG=${IMAGE_TAG}

CMD ["sh", "-c", "npm start"]

