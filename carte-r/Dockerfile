# CARTE-R Container based Analysis RunTime Environment for R

# Based on Rocker r-apt image
# https://github.com/rocker-org/rocker-versioned
#
# docker build --no-cache=true --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') --build-arg BUILD_VERSION="test" -t carte-r:latest .

FROM rocker/r-apt:bionic

ARG BUILD_DATE
ARG BUILD_VERSION="test"
ARG R_VERSION
# Path to User installed libraries
ARG R_SITE_LIBRARY_PATH="/usr/local/lib/R/site-library"

# Kallisto version to install
ARG KALLISTO_VERSION="v0.46.0"

# Mountpint for externally mounted volume
ARG VOLUME_PATH="/work"

LABEL org.label-schema.name="carte-r" \
	  org.label-schema.description="CARTE-R is a container image that provides runtime environment for analysis workflows using R" \
	  org.label-schema.version="$BUILD_VERSION" \
	  org.label-schema.build-date="$BUILD_DATE" \
	  org.label-schema.license="GPL-2.0" \
      org.label-schema.vcs-url="https://github.com/rajivnarayan/carte/carte-r" \
      org.label-schema.schema-version="1.0"

## Install system dependencies
RUN apt-get update \
  && BUILD_DEPS="\
  # system tools
  autoconf \
  bash-completion \
  cmake \
  file \
  git \
  jq \
  mc \
  ## system libraries
  libcairo2-dev \
  libcurl4-openssl-dev \
  libhdf5-100 \
  libhdf5-dev \
  libmariadbd-dev \
  libmariadb-client-lgpl-dev \
  libopenblas-dev \
  libpq-dev \
  libsasl2-dev \
  libssh2-1-dev \
  libssl-dev \
  libsqlite3-dev \
  libxml2-dev \
  unixodbc-dev \
  zlib1g-dev \
  # Binary R packages
  r-cran-arules \
  r-cran-base64enc \
  r-cran-bigrquery \
  r-cran-biocmanager \
  r-bioc-biomart \
  r-cran-bitops \
  r-cran-caret \
  r-cran-catools \
  r-cran-curl \
  r-cran-data.table \
  r-cran-dendextend \
  r-cran-devtools \
  r-cran-doparallel \
  r-cran-dplyr \
  r-bioc-edger \
  r-cran-e1071 \
  r-cran-fastcluster \
  r-cran-foreach \
  r-cran-formatr \
  r-cran-futile.logger \
  r-cran-ggally \
  r-cran-ggplot2 \
  r-cran-ggpubr \
  r-cran-ggrepel \
  r-cran-glmnet \
  r-cran-gridextra \
  r-cran-gtable \
  r-cran-ggvis \
  r-cran-highr \
  r-cran-htmltools \
  r-cran-httr \
  r-cran-igraph \
  r-cran-knitr \
  r-bioc-limma \
  r-cran-markdown \
  r-cran-mvtnorm \
  r-cran-pcapp \
  r-cran-pheatmap \
  r-cran-psych \
  r-cran-rcolorbrewer \
  r-bioc-rhdf5lib \
  r-bioc-rhdf5 \
  r-cran-remotes \
  r-cran-rmarkdown \
  r-cran-rprojroot \
  r-cran-rrcov \
  r-cran-rtsne \
  r-cran-selectr \
  r-cran-tidyverse \
  r-cran-testthat \
  r-cran-yaml" \
  && apt-get install -y --no-install-recommends $BUILD_DEPS \
## Install R packages with missing binaries from source
  && R -e "SRC_PACKAGE <- c('gastonstat/arcdiagram', \
  'circlize', \
  'prada', \
  'Glimma', \
  'sva', \
  'cmap/cmapR'); \
  BiocManager::install(SRC_PACKAGE, update=F)" \
## Install kallisto
  && cd /tmp \
  && git clone https://github.com/pachterlab/kallisto.git \
  && cd kallisto \
  && git checkout -b ${KALLISTO_VERSION} \
  && mkdir build; cd build \
  && cmake .. \
  && make \
  && make install \
## Install z directory navigation utility
  && wget https://raw.githubusercontent.com/rupa/z/master/z.sh \
          -o /etc/profile.d/z.sh \
## Clean up source install
  && cd / \
  && rm -rf /tmp/* \
  && apt-get autoremove -y \
  && apt-get autoclean -y \
  && rm -rf /var/lib/apt/lists/*

VOLUME ["$VOLUME_PATH"]

# TODO
# Packages to Add
# 'pachterlab/sleuth' # note has many dependencies
# Mini latex distributiion tinytex
