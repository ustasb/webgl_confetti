FROM ruby:2.4.1-alpine3.6
MAINTAINER Brian Ustas <brianustas@gmail.com>

ARG APP_PATH="/opt/webgl_confetti"

RUN apk add --update \
  nodejs \
  nodejs-npm \
  && rm -rf /var/cache/apk/*

# CoffeeScript
RUN npm install -g coffeescript@1.6.3

WORKDIR $APP_PATH
COPY . $APP_PATH

RUN rake build_public

VOLUME $APP_PATH
