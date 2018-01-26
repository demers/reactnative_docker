# Docker image for React Native and Android.

FROM ubuntu:14.04

MAINTAINER FND <fndemers@gmail.com>


# Setup environment variables
ENV PATH $PATH:node_modules/.bin

ENV WORKDIRECTORY /opt/workspace
ENV WORKPROJECT project

RUN apt-get update

RUN apt-get install -y python-dev unzip vim-nox

# Installation Java.
#RUN apt-get install -qy --no-install-recommends python-dev default-jdk
RUN apt-get install -y software-properties-common \
    && add-apt-repository -y ppa:webupd8team/java \
    && apt-get update
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 \
    select true | /usr/bin/debconf-set-selections
RUN apt-get install -y oracle-java8-installer
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle/

# Install Deps
RUN dpkg --add-architecture i386 && apt-get update \
    && apt-get install -y --force-yes expect wget \
    libc6-i386 lib32stdc++6 lib32gcc1 lib32ncurses5 lib32z1

# Install Android SDK
RUN cd /opt && wget --quiet --output-document=android-sdk.tgz \
    http://dl.google.com/android/android-sdk_r24.3.3-linux.tgz \
    && tar xzf android-sdk.tgz && rm -f android-sdk.tgz \
    && chown -R root.root android-sdk-linux

# Setup environment
ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools
ENV GRADLE_USER_HOME "~/.gradle"

# Install sdk elements
COPY tools /opt/tools
ENV PATH ${PATH}:/opt/tools
RUN ["/opt/tools/android-accept-licenses.sh", \
    "android update sdk --all --force --no-ui --filter platform-tools,tools,build-tools-23,build-tools-23.0.2,android-23,addon-google_apis_x86-google-23,extra-android-support,extra-android-m2repository,extra-google-m2repository,extra-google-google_play_services,sys-img-armeabi-v7a-android-23"]

# Unzip tools if not unzipped.
# Strange that it is not uncompressed.
RUN cd ${ANDROID_HOME} \
    && unzip -o -q ${ANDROID_HOME}/temp/tools_r25.2.5-linux.zip

#RUN /opt/tools/android-accept-licenses.sh \
#    "android update sdk --all --force --no-ui --filter platform-tools,tools,build-tools-23,build-tools-23.0.2,android-23,addon-google_apis_x86-google-23,extra-android-support,extra-android-m2repository,extra-google-m2repository,extra-google-google_play_services,sys-img-armeabi-v7a-android-23" \
#    && /opt/tools/android-accept-licenses2.sh \
#    "/opt/android-sdk-linux/tools/bin/sdkmanager --update"

#RUN /opt/android-sdk-linux/tools/bin/sdkmanager --update
RUN ["/opt/tools/android-accept-licenses2.sh", \
    "/opt/android-sdk-linux/tools/bin/sdkmanager --update"]

# Install Node.JS
RUN apt-get install -y curl \
    && curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash - \
    && apt-get install -y nodejs

# Installation React Native
# Install yarn
RUN npm install -g npm \
    && npm install -g n \
    && npm cache clean -f \
# Installation npm et mise à jour
    && n stable \
    && npm install -g react-native-cli \
    && npm install -g create-react-native-app \
    && npm install -g yarn

# Installation du système de test Jest https://facebook.github.io/jest/
RUN npm install --save-dev jest

# Install watchman
RUN apt-get install -y git autoconf automake build-essential libtool libssl-dev libcurl4-openssl-dev libcrypto++-dev
RUN git clone https://github.com/facebook/watchman.git \
    && cd watchman && git checkout v4.7.0 && ./autogen.sh && ./configure && make && make install \
    && cd .. && rm -rf watchman

## Clean up when done
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Default react-native web server port
EXPOSE 8081

RUN mkdir -p ${WORKDIRECTORY}

# Copy the project called ${WORKPROJECT}.zip
#RUN mkdir -p ${WORKDIRECTORY}/${WORKPROJECT}
#COPY ${WORKPROJECT}.zip ${WORKDIRECTORY}/${WORKPROJECT}
#RUN cd ${WORKDIRECTORY}/${WORKPROJECT} \
#    && unzip ${WORKPROJECT}.zip

# Install dependences
#RUN cd ${WORKDIRECTORY}/${WORKPROJECT} \
#    && npm install

# Go to workspace
WORKDIR ${WORKDIRECTORY}

# Variables to generate Android Key
# First and last name?
ENV KEYTOOL_CN "Android Android"
# the name of your organizational unit?
ENV KEYTOOL_OU "Android Android"
# the name of your organization?
ENV KEYTOOL_O "Android Android"
# the name of your City or Locality?
ENV KEYTOOL_L "Quebec"
# the name of your State or Province?
ENV KEYTOOL_S "Quebec"
# What is the two-letter country code for this unit?
ENV KEYTOOL_C "CA"
# Storepass
ENV KEYTOOL_STOREPASS "androidandroid"
# Keypass
ENV KEYTOOL_KEYPASS "androidandroid"

# DName
ENV KEYTOOL_DNAME "CN=${KEYTOOL_CN}, OU=${KEYTOOL_OU}, O=${KEYTOOL_O}, L=${KEYTOOL_L}, S=${KEYTOOL_S}, C=${KEYTOOL_C}"

# It is not necessary to generate a key.
# Creation Android key.
#RUN cd ${WORKDIRECTORY}/${WORKPROJECT}/android/app \
#    && rm -f my-release-key.keystore \
#    && keytool -genkey -v -keystore my-release-key.keystore -alias my-key-alias -keyalg RSA -keysize 2048 -validity 10000 -dname "${KEYTOOL_DNAME}" -storepass "${KEYTOOL_STOREPASS}" -keypass "${KEYTOOL_KEYPASS}"

#RUN cd ${WORKDIRECTORY}/${WORKPROJECT}/android \
#    && chmod +x ./gradlew \
#    && ./gradlew assembleRelease


# Création d'un projet TEST
RUN react-native init AwesomeProject \
    && cd AwesomeProject \
    && npm install \
    && cd android \
    && chmod +x ./gradlew \
    && ./gradlew assembleRelease

RUN mkdir -p ${WORKDIRECTORY}/publish

RUN cp -f ./app/build/outputs/apk/app-release-unsigned.apk ${WORKDIRECTORY}/publish

#RUN create-react-native-app AwesomeProject \
#    && cd AwesomeProject \
#    && npm start

# Commande qui ne fonctionne pas...
#RUN react-native build-android --release AwesomeProject

# Port publish access
EXPOSE 5000

# Publier l'APK sur le Web sur le port 5000.
RUN apt-get install -y ruby
RUN cd ${WORKDIRECTORY}/publish \
    && ruby -run -e httpd . -p5000

