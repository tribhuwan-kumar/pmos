FROM debian:stable-slim

RUN apt update && apt install -y \
    curl unzip openjdk-21-jdk-headless fuse3 \
    && apt clean

WORKDIR /opt/cryptomator

RUN curl -L -o cli.zip \
    https://github.com/cryptomator/cli/releases/download/0.6.2/cryptomator-cli-0.6.2-linux-aarch64.zip \
    && unzip cli.zip \
    && rm cli.zip

RUN cd /opt/cryptomator && \
    EXTRACTED=$(ls -d */ | head -n 1 | tr -d '/') && \
    ln -s "/opt/cryptomator/$EXTRACTED/bin/cryptomator-cli" /usr/local/bin/cryptomator-cli

ENV PATH="/opt/cryptomator/bin:${PATH}"
RUN mkdir -p /vaults /mounts
ENTRYPOINT ["cryptomator-cli"]

# dummy process, so container won't exit
CMD ["sleep", "infinity"]
