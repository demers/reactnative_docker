# reactnative_docker
Serveur React Native pour Docker

Installations:
* Android SDK
* React Native
* Jest (test)

Pour démarrer un émulateur et démarrer React Native comme
sur un poste de travail Linux ordinaire, inspirez-vous ce projet:
https://github.com/gilesp/docker/tree/master/react_native

Pour générer le code APK avec Gradle, il faut s'assurer que dans le fichier
gradle/wrapper/gradle-wrapper.properties l'URL soit HTTP et non HTTPS.


distributionUrl=http\://services.gradle.org/distributions/gradle-*-all.zip

Quelques liens en référence:

* https://hub.docker.com/r/jacekmarchwicki/android/
* https://ncona.com/2016/07/android-development-with-docker/
* https://github.com/MaximeD/docker-react-native
* https://github.com/gilesp/docker/tree/master/react_native
* https://staminaloops.github.io/undefinedisnotafunction/install-react-native-ubuntu/
* https://stackoverflow.com/questions/29576871/cant-build-android-app-with-gradle
