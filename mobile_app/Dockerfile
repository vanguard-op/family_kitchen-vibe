FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    openjdk-11-jdk-headless \
    wget

RUN git clone https://github.com/flutter/flutter.git --depth 1 -b stable /flutter
RUN /flutter/bin/flutter config --android-sdk /opt/android-sdk
RUN /flutter/bin/flutter precache

WORKDIR /app
COPY pubspec.yaml pubspec.lock* ./
RUN /flutter/bin/flutter pub get

COPY . .

RUN /flutter/bin/flutter build apk --release --split-per-abi

FROM scratch
COPY --from=0 /app/build/app/outputs/bundle/release/app-release.apk /family-kitchen.apk
