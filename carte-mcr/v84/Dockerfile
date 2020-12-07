# CARTE-MCR Container based Analysis RunTime Environment for 
# Matlab Container Runtime (MCR)
# https://www.mathworks.com/products/compiler/matlab-runtime.html
# This Dockerfile configures an environment with MCR and enables 
# executing compiled Matlab routines 

# docker build --no-cache=true --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') --build-arg BUILD_VERSION="test" -t carte-mcr:latest .

FROM bitnami/minideb:latest

ARG BUILD_DATE
ARG BUILD_VERSION="test"
# Matlab compiler runtime release
ARG MCR_RELEASE='R2014b'
# MCR version number
ARG MCR_VERSION_NUM='v84'

# Mountpint for externally mounted volume
ARG VOLUME_PATH="/opt"

# Install Location of MCR
ARG MCR_INSTALL_PATH=${VOLUME_PATH}/mcr

# location of MCR files
ENV MCR_ROOT="${MCR_INSTALL_PATH}/${MCR_VERSION_NUM}"

# installer URL
ARG MCR_URL="https://ssd.mathworks.com/supportfiles/downloads/${MCR_RELEASE}/deployment_files/${MCR_RELEASE}/installers/glnxa64/MCR_${MCR_RELEASE}_glnxa64_installer.zip"

ENV DEBIAN_FRONTEND noninteractive

LABEL org.label-schema.name="carte-mcr" \
	  org.label-schema.description="CARTE-MCR is a container image that provides Matlab's container runtime (MCR)" \
	  org.label-schema.version="$BUILD_VERSION" \
	  org.label-schema.build-date="$BUILD_DATE" \
	  org.label-schema.license="GPL-2.0" \
      org.label-schema.vcs-url="https://github.com/rajivnarayan/carte/carte-mcr" \
      org.label-schema.schema-version="1.0"

RUN install_packages \
  wget \
  tar \
  unzip \
  libxt-dev \
  libxtst6 \
  libncurses5 \
  libxext6 \
  libxmu6 \
  libxpm-dev \
  libxt6 \
&& mkdir -p /tmp/mcr_installer $MCR_INSTALL_PATH \
## Download MCR
&& cd /tmp/mcr_installer \
&& echo "Downloading MCR from: $MCR_URL" \
&& wget --no-verbose --no-check-certificate -S "$MCR_URL" -O mcr_installer.zip \
&& unzip -q mcr_installer.zip \
## Install MCR
&& ./install -mode silent -agreeToLicense Yes -destinationFolder "$MCR_INSTALL_PATH" \
## Cleanup
&& cd / \
&& rm -rf /tmp/* \
&& apt-get autoremove -y \
&& apt-get autoclean -y \
&& rm -rf /var/lib/apt/lists/* \
## Remove extraneous MCR files
&& rm -rf /opt/mcr/v84/sys/jxbrowser-chromium \
&& find  /opt/mcr/ -name 'ja_JP' -type d -prune -exec rm -r {} \;

# Configure library paths to MCR
# Note that setting LD_LIBRARY_PATH breaks other apps so as a workaround
# save paths to alternate variable instead and use as:
# LD_LIBRARY_PATH=$MCR_LIBRARY_PATH <matlab_program> args
ENV MCR_LD_LIBRARY_PATH "${MCR_ROOT}/runtime/glnxa64:${MCR_ROOT}/bin/glnxa64:${MCR_ROOT}/sys/os/glnxa64"
ENV XAPPLRESDIR ${MCR_ROOT}/X11/app-defaults

VOLUME ["$VOLUME_PATH"]

CMD ["bash"]
