FROM ubuntu:22.04

ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends tzdata curl ca-certificates fontconfig locales binutils \
    && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

ENV JBR_VERSION jbr-17

RUN set -eux; \
    ARCH="$(dpkg --print-architecture)"; \
    case "${ARCH}" in \
       amd64|i386:x86-64) \
         ESUM='6bb57dc6d1ef7543f7f96ce7905fd894ffbf672e1e0db22c4483927982f5c3a5'; \
         BINARY_URL='https://cache-redirector.jetbrains.com/intellij-jbr/jbr_dcevm-17-linux-x64-b135.1.tar.gz'; \
         ;; \
       *) \
         echo "Unsupported arch: ${ARCH}"; \
         exit 1; \
         ;; \
    esac; \
    curl -LfsSo /tmp/jbr.tar.gz ${BINARY_URL}; \
    echo "${ESUM} */tmp/jbr.tar.gz" | sha256sum -c -; \
    mkdir -p /opt/jbr; \
    cd /opt/jbr; \
    tar -xf /tmp/jbr.tar.gz --strip-components=1; \
    rm -rf /tmp/jbr.tar.gz;

ENV JAVA_HOME=/opt/jbr \
    PATH="/opt/jbr/bin:$PATH"

RUN echo Verifying install ... \
    && echo java --version && java --version \
    && echo Complete.

CMD ["jshell"]
