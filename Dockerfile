FROM ruby:alpine

ENV APP_HOME /app
ENV HOME /root
ENV CHROME_BIN=/usr/bin/chromium-browser \
    CHROME_PATH=/usr/lib/chromium/
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

RUN apk update && apk upgrade \
    && echo @latest-stable http://nl.alpinelinux.org/alpine/latest-stable/community >> /etc/apk/repositories \
    && echo @latest-stable http://nl.alpinelinux.org/alpine/latest-stable/main >> /etc/apk/repositories \
    && echo @edge-testing http://dl-cdn.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories \
    && echo @edge-main http://dl-cdn.alpinelinux.org/alpine/edge/main >> /etc/apk/repositories

RUN apk add build-base gcc
RUN apk add libffi-dev ruby-dev ruby-rdoc ruby-webrick@latest-stable zlib-dev
RUN apk add chromium-chromedriver chromium@latest-stable harfbuzz@latest-stable nss@latest-stable
RUN apk add cmake cmake-doc extra-cmake-modules extra-cmake-modules-doc


COPY Gemfile* $APP_HOME/

RUN bundle install

COPY . $APP_HOME
