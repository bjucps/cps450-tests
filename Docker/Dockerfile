FROM ubuntu:22.04 
RUN apt-get update && apt-get install -y curl unzip \
    && apt-get clean

RUN curl -L --insecure https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.1%2B12/OpenJDK21U-jdk_x64_linux_hotspot_21.0.1_12.tar.gz --output jdk.tgz --silent && \
    tar zxf jdk.tgz && \
    rm jdk.tgz && \
    ln -s /jdk-21.0.1+12/bin/java /usr/bin && \
    ln -s /jdk-21.0.1+12/bin/javac /usr/bin

RUN curl -L --insecure "https://services.gradle.org/distributions/gradle-8.5-bin.zip" --output gradle.zip --silent && \
    unzip -q gradle.zip && rm gradle.zip

ENV PATH="/gradle-8.5/bin:${PATH}"
ENV GRADLE_USER_HOME="/tmp/.gradle"

COPY Docker/setup.sh .
COPY lexer /lexer/
RUN bash -v setup.sh
