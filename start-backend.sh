#!/bin/bash
cd "$(dirname "$0")/backend"
export JAVA_HOME="/opt/homebrew/opt/openjdk@21"
export PATH="$JAVA_HOME/bin:$PATH"
./mvnw spring-boot:run
