# syntax=docker/dockerfile:1
#
# One image: the Go server with the Flutter web app embedded.
#   docker build -t balnana .
# See docker-compose.yml and .env.example for running it.

ARG FLUTTER_VERSION=3.47.8
ARG GO_VERSION=1.26

# --- Flutter web build --------------------------------------------------------
FROM debian:bookworm-slim AS web
ARG FLUTTER_VERSION
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl git unzip xz-utils \
 && rm -rf /var/lib/apt/lists/*
RUN git clone --depth 1 --branch "${FLUTTER_VERSION}" https://github.com/flutter/flutter.git /opt/flutter
ENV PATH=/opt/flutter/bin:$PATH
RUN flutter config --no-analytics --no-cli-animations >/dev/null \
 && flutter precache --web

WORKDIR /src/app
COPY app/pubspec.yaml app/pubspec.lock ./
RUN flutter pub get
COPY app/ ./
# No CDN: a self-hosted server serves every web resource itself.
RUN flutter build web --release --no-web-resources-cdn

# --- Go build -------------------------------------------------------------------
FROM golang:${GO_VERSION}-alpine AS server
WORKDIR /src/server
COPY server/go.mod server/go.sum ./
RUN go mod download
COPY server/ ./
COPY --from=web /src/app/build/web ./internal/web/dist/
ARG VERSION=dev
RUN CGO_ENABLED=0 go build -trimpath -ldflags "-s -w -X main.version=${VERSION}" -o /out/balnana ./cmd/balnana

# --- Runtime ----------------------------------------------------------------------
FROM gcr.io/distroless/static-debian12:nonroot
LABEL org.opencontainers.image.title="Balnana" \
      org.opencontainers.image.description="Self-hosted group expense splitter" \
      org.opencontainers.image.licenses="AGPL-3.0-only"
COPY LICENSE /LICENSE
COPY --from=server /out/balnana /balnana
ENV BALNANA_LISTEN=:8080
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s CMD ["/balnana", "healthcheck"]
ENTRYPOINT ["/balnana"]
