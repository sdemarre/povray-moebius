# Stage 1: Build
FROM ubuntu:22.04 AS builder

# Install necessary build dependencies
RUN apt update && \
    apt install -y build-essential autoconf libboost-thread-dev zlib1g-dev libpng-dev libjpeg-dev libtiff-dev

COPY povray /app

WORKDIR /app/unix
RUN ./prebuild.sh

WORKDIR /app
RUN ./configure COMPILED_BY="serge<serge@serge.com>"
RUN make && make install

# Stage 2: Runtime
FROM ubuntu:22.04

# Install runtime dependencies if any
RUN apt update && \
    apt install -y libboost-thread1.74.0 zlib1g libpng-dev libjpeg-dev libtiff-dev

# Copy necessary build artifacts from builder stage
COPY --from=builder /usr/local/bin/povray /usr/local/bin/povray
COPY --from=builder /usr/local/share/man/man1/povray.1 /usr/local/share/man/man1/povray.1
COPY --from=builder /usr/local/etc/povray/3.7/povray.conf /usr/local/etc/povray/3.7/povray.conf
COPY --from=builder /usr/local/share/povray-3.7 /usr/local/share/povray-3.7
COPY --from=builder /usr/local/etc/povray/3.7/povray.ini /usr/local/etc/povray/3.7/povray.ini
COPY --from=builder /usr/local/share/doc/povray-3.7 /usr/local/share/doc/povray-3.7

RUN groupadd -r povray -g 1000 && useradd -r -g povray -u 1000 povray
RUN mkdir /home/povray
RUN chown povray:povray /home/povray
WORKDIR /home/povray
USER povray
