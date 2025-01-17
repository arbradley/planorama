# Dockerfile

# Use ruby image to build our own image
FROM --platform=linux/x86_64 ruby:2.7.2-alpine as base

# Ensure that we work in UTF 8
ENV LANG C.UTF-8 # ensure that the encoding is UTF8
ENV LANGUAGE C.UTF-8 # ensure that the encoding is UTF8

# Specify an external volume for the Application source
# VOLUME ["/opt/planorama"]

# Use a persistent volume for the gems installed by the bundler
ENV BUNDLE_PATH /var/bundler

RUN apk add \
      build-base \
      freetds-dev \
      git \
      less \
      netcat-openbsd \
      nodejs \
      nodejs-npm \
      postgresql-client \
      postgresql-dev \
      pkgconfig \
      openssl \
      shared-mime-info \
      tzdata \
      yarn \
    && rm -rf /var/cache/apk/*

# Install bundler for this Docker image
RUN gem install bundler:2.2.4

# WORKDIR /setup
ADD . /opt/planorama
WORKDIR /opt/planorama

RUN bundle install
RUN yarn install --frozen-lockfile
RUN bundle exec rake assets:precompile

# We expose the port
EXPOSE 3000

VOLUME /app

CMD script/docker_web_entry.sh
