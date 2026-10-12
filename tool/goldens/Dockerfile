FROM ubuntu:24.04
ARG FLUTTER_VERSION
RUN apt-get update \
    && apt-get install -y --no-install-recommends git curl unzip xz-utils ca-certificates \
    && rm -rf /var/lib/apt/lists/*
RUN git clone --depth 1 --branch "$FLUTTER_VERSION" https://github.com/flutter/flutter.git /flutter
ENV PATH=/flutter/bin:$PATH
RUN git config --global --add safe.directory '*' \
    && flutter precache --no-android --no-ios --no-web --linux
