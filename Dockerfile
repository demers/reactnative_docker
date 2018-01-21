# Docker image for react native.

FROM ubuntu:14.04

MAINTAINER FND <fndemers@gmail.com>


# Setup environment variables
ENV PATH $PATH:node_modules/.bin

RUN apt-get update

RUN apt-get install -qy --no-install-recommends python-dev default-jdk

# Install Deps
RUN dpkg --add-architecture i386 && apt-get update \
    && apt-get install -y --force-yes expect wget \
    libc6-i386 lib32stdc++6 lib32gcc1 lib32ncurses5 lib32z1

# Install Android SDK
RUN cd /opt && wget --output-document=android-sdk.tgz --quiet \
    http://dl.google.com/android/android-sdk_r24.3.3-linux.tgz \
    && tar xzf android-sdk.tgz && rm -f android-sdk.tgz \
    && chown -R root.root android-sdk-linux

# Setup environment
ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools

# Install sdk elements
COPY tools /opt/tools
ENV PATH ${PATH}:/opt/tools
RUN ["/opt/tools/android-accept-licenses.sh", \
    "android update sdk --all --force --no-ui --filter platform-tools,tools,build-tools-23,build-tools-23.0.2,android-23,addon-google_apis_x86-google-23,extra-android-support,extra-android-m2repository,extra-google-m2repository,extra-google-google_play_services,sys-img-armeabi-v7a-android-23"]

# Install Node.JS
RUN apt-get install -y curl git
RUN curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
RUN apt-get install -y nodejs

# Mise à jour
RUN npm install -g npm

## Install react native
RUN npm install -g react-native-cli

## Clean up when done
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# Install watchman
#RUN git clone https://github.com/facebook/watchman.git
#RUN cd watchman && git checkout v4.7.0 && ./autogen.sh && ./configure && make && make install
#RUN rm -rf watchman

# Default react-native web server port
EXPOSE 8081

# Installation du système de test Jest https://facebook.github.io/jest/
RUN npm install --save-dev jest

# Création d'un projet TEST
RUN react-native init AwesomeProject

# Go to workspace
RUN mkdir -p /opt/workspace
WORKDIR /opt/workspace
