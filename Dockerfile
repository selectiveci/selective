FROM ruby:2.6.6

LABEL maintainer="Benjamin Wood <ben@hint.io>"

ARG DEBIAN_FRONTEND=noninteractive

###############################################################################
# Base Software Install
###############################################################################

RUN apt-get update && apt-get install -y \
    build-essential \
    yarn \
    locales \
    git \
    netcat \
    vim \
    sudo

###############################################################################
# Non-root user
###############################################################################

# TODO remove UID GID defaults
ARG UID
ENV UID $UID
ARG GID
ENV GID $GID
ARG USER=ruby
ENV USER $USER

RUN groupadd -g $GID $USER && \
    useradd -u $UID -g $USER -m $USER && \
    usermod -p "*" $USER && \
    usermod -aG sudo $USER && \
    echo "$USER ALL=NOPASSWD: ALL" >> /etc/sudoers.d/50-$USER

###############################################################################
# Ruby, Rubygems, and Bundler Defaults
###############################################################################

ENV LANG C.UTF-8

# Update Rubygems to latest
RUN gem update --system

# Point Bundler at /gems. This will cause Bundler to re-use gems that have already been installed on the gems volume
ENV BUNDLE_HOME /gems

# Increase how many threads Bundler uses when installing. Optional!
ENV BUNDLE_JOBS 20

# How many times Bundler will retry a gem download. Optional!
ENV BUNDLE_RETRY 5

# Where Rubygems will look for gems, similar to BUNDLE_ equivalents.
ENV GEM_HOME /gems
ENV GEM_PATH /gems

# Add /gems/bin to the path so any installed gem binaries are runnable from bash.
ENV PATH ${GEM_HOME}/bin:${GEM_HOME}/gems/bin:$PATH

RUN unset BUNDLE_PATH && unset BUNDLE_BIN

###############################################################################
# Final Touches
###############################################################################

RUN mkdir -p "$GEM_HOME" && chown $USER:$USER "$GEM_HOME"
RUN mkdir -p /gem && chown $USER:$USER /gem

WORKDIR /gem

USER $USER

# Install latest bundler
RUN gem install bundler
