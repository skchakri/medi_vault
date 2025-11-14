#!/bin/bash
# Build script for Android app
# Sets JAVA_HOME to Android Studio's JBR

export JAVA_HOME=/home/kalyan/Desktop/android-studio/jbr
export PATH=$JAVA_HOME/bin:$PATH

# Run gradlew with all passed arguments
./gradlew "$@"
