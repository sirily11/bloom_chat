FROM swift:5.7.3-focal as build



# Install OS updates and, if needed, sqlite3
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && rm -rf /var/lib/apt/lists/*


WORKDIR /app/


COPY Package.swift /app/
COPY Sources /app/Sources
COPY Tests /app/Tests

RUN swift build -c release --static-swift-stdlib

WORKDIR /build
RUN cp /app/.build/release/BloomChat .
RUN cp -r /app/.build/release/BloomChat_BloomChat.resources .

FROM ubuntu:22.10 as run

ARG APP_NAME
WORKDIR /app

RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true && apt-get -q update && \
    apt-get -q install -y \
    libcurl4 \
    libxml2 \
    tzdata \
    && rm -r /var/lib/apt/lists/*


COPY --from=build /build/BloomChat /app
COPY --from=build /build/BloomChat_BloomChat.resources /app/BloomChat_BloomChat.resources

ENTRYPOINT [ "./BloomChat" ]
CMD []