FROM rust:1-slim-bookworm AS builder
RUN apt-get update && apt-get install -y pkg-config libssl-dev && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY server/ .
RUN cargo build --release

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y chromium chromium-l10n ca-certificates && rm -rf /var/lib/apt/lists/*
ENV CHROME_PATH=/usr/bin/chromium
COPY --from=builder /app/target/release/sc-synthesis-server /usr/local/bin/
EXPOSE 3001
CMD ["sc-synthesis-server", "--bind", "0.0.0.0:3001"]
