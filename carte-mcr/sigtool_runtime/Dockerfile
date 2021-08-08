# CMap sigtool-runtime
# This Dockerfile configures a runtime environment for executing
# command-line implementations of core Connectivity Map algorithms (aka sig-tools)
# Build using:
# cd assets; docker build -f ../Dockerfile --no-cache=true --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') --build-arg BUILD_VERSION="test" -t sigtool-runtime:latest .

# Matlab Compiler Runtime Docker image
FROM quay.io/rajivnarayan/carte-mcr-v95:latest

ARG BUILD_DATE
ARG BUILD_VERSION="latest"

ENV DEBIAN_FRONTEND noninteractive

LABEL org.label-schema.name="sigtool-runtime" \
  org.label-schema.description="Provides a containerized runtime environment to execute CMap sig-tools" \
  org.label-schema.version="$BUILD_VERSION" \
  org.label-schema.build-date="$BUILD_DATE" \
  org.label-schema.license="GPL-2.0" \
  org.label-schema.schema-version="1.0"

# Copy sigtool run scripts
COPY ./* /usr/local/bin/

RUN install_packages \
  bc \
  gnuplot \
  vim-tiny \
  procps \
## set permissions for sig-tool scripts
&& chmod +x /usr/local/bin/* \
## Cleanup
&& rm -rf /tmp/* \
&& apt-get autoremove -y \
&& apt-get autoclean -y \
&& rm -rf /var/lib/apt/lists/*

CMD ["run-sigtool"]
