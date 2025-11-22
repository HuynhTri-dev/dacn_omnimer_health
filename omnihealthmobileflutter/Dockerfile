FROM ghcr.io/cirruslabs/flutter:3.24 as builder

WORKDIR /app

COPY . .
RUN flutter pub get
RUN flutter build web --release
