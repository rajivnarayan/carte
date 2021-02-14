# CARTE-R A Container based Analysis RunTime Environment for R
#
# 
# Based on Rocker r-apt image
# https://github.com/rocker-org/rocker-versioned
#
# docker build --no-cache=true --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') --build-arg BUILD_VERSION="test" -t carte-r:latest .

FROM rocker/r-apt:bionic

ARG BUILD_DATE
ARG BUILD_VERSION="latest"
# non-root user 
# Change using --build-arg CARTE_USER='myname" 
ARG CARTE_USER='carte'
# Change using --build-arg CARTE_PASSWORD="mypassword"
ARG CARTE_PASSWORD='carte:)'

# Mountpint for externally mounted volume
ARG VOLUME_PATH="/work"

# R config options
ARG R_VERSION="3.6"
# Path to User installed libraries
ARG R_SITE_LIBRARY_PATH="/usr/local/lib/R/site-library"

# S6 process supervisor options
ARG S6_VERSION
ENV S6_VERSION=${S6_VERSION:-v1.21.7.0}
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2

# Kallisto options
ARG KALLISTO_VERSION="v0.46.0"

# TinyTex installation path
ARG TINYTEX_DIR='/opt/tinytex'

LABEL org.label-schema.name="carte-r" \
	  org.label-schema.description="CARTE-R is a container image that provides runtime environment for data analysis using the R programming language" \
	  org.label-schema.version="$BUILD_VERSION" \
	  org.label-schema.build-date="$BUILD_DATE" \
	  org.label-schema.license="GPL-2.0" \
      org.label-schema.vcs-url="https://github.com/rajivnarayan/carte/carte-r" \
      org.label-schema.schema-version="1.0"

# copy config files
COPY root /

## Install system dependencies
RUN apt-get update \
  && BUILD_DEPS="\
 ## system tools
  autoconf \
  bash-completion \
  cmake \
  curl \
  file \
  git \
  # JSON utility
  jq \
  # text-based file manager
  mc \
  # text-editor
  vim \
  sudo \
  gosu \
  # for installing local packages r-studio and shiny
  gdebi-core \
  openssh-client \
  rsync \
 ## system library dependencies
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
 ## Matlab MCR dependencies
  libncurses5 \
  libxext6 \
  libxmu6 \
  libxt6 \
  ## Nice Google fonts
  fonts-roboto \
  ## used by some base R plots
  ghostscript \
  ## used to build rJava and other packages
  libbz2-dev \
  libicu-dev \
  liblzma-dev \
  ## system dependency of hunspell (devtools)
  libhunspell-dev \
  ## system dependency of hadley/pkgdown
  libmagick++-dev \
  ## rdf, for redland / linked data
  #librdf0-dev \
  #libraptor2-dev \
  #librasqal3-dev \
  #libcurl4-gnutls-dev \
  ## for V8-based javascript wrappers
  libv8-dev \
  ## R CMD Check wants qpdf to check pdf sizes, or throws a Warning
  qpdf \
  ## For building PDF manuals
  texinfo \
  ## parallelization
  libzmq3-dev \
  libopenmpi-dev \
  # Binary R packages
  r-cran-arules \
  r-cran-base64enc \
  r-cran-bigrquery \
  r-cran-biocmanager \
  r-bioc-biomart \
  r-cran-bitops \
  r-cran-caret \
  r-cran-catools \
  r-cran-circlize \
  r-cran-curl \
  r-cran-data.table \
  r-cran-dendextend \
  r-cran-devtools \
  r-bioc-deseq2 \
  r-cran-doparallel \
  r-cran-dplyr \
  r-cran-dt \
  r-bioc-edger \
  r-cran-e1071 \
  r-cran-fastcluster \
  r-cran-foreach \
  r-cran-formatr \
  r-cran-futile.logger \
  r-bioc-genefilter \
  r-cran-gert \
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
  r-cran-huxtable \
  r-cran-ineq \
  r-cran-igraph \
  r-cran-jsonlite \
  r-cran-knitr \
  r-bioc-limma \
  r-cran-markdown \
  r-cran-mvtnorm \
  r-cran-pcapp \
  r-cran-pheatmap \
  r-cran-plotly \
  r-cran-psych \
  r-bioc-qvalue \
  r-cran-ranger \
  r-cran-rcolorbrewer \
  r-bioc-rhdf5lib \
  r-bioc-rhdf5 \
  r-cran-remotes \
  r-cran-rmarkdown \
  r-cran-rprojroot \
  r-cran-rrcov \
  r-cran-rtsne \
  r-bioc-summarizedexperiment \
  r-cran-selectr \
  r-cran-seqinr \
  r-cran-tidyverse \
  r-cran-testthat \
  r-cran-usethis \
  r-cran-xgboost \
  r-cran-xml2 \
  r-cran-yaml" \
  && apt-get install -y --no-install-recommends $BUILD_DEPS \
## Install missing R packages from CRAN and Bioconductor
  && install2.r --skipinstalled \
   --repos "http://bioconductor.org/packages/${R_VERSION}/bioc" \
   --repos "https://cloud.r-project.org" \
   'GetoptLong' \
   'ComplexHeatmap' \
   'prada' \
   'Glimma' \
   'sva' \
   'flexdashboard' \
   'uwot' \
## Install packages from Github
  && installGithub.r --update FALSE \
   'gastonstat/arcdiagram' \
   'cmap/cmapR' \
   'pachterlab/sleuth' \
   'rstudio/crosstalk' \
   'jcheng5/d3scatter' \
## Use tinytex for LaTeX installation
  && install2.r --error tinytex \
  ## Admin-based install of TinyTeX:
  && wget -qO- \
    "https://github.com/yihui/tinytex/raw/master/tools/install-unx.sh" | \
    TINYTEX_DIR=${TINYTEX_DIR} sh -s - --admin --no-path \
  && ${TINYTEX_DIR}/bin/*/tlmgr path add \
  && tlmgr install ae inconsolata listings metafont mfware parskip pdfcrop tex \
  && tlmgr path add \
  && Rscript -e "tinytex::r_texmf()" \
  && chown -R root:staff ${TINYTEX_DIR} \
  && chown -R root:staff /usr/local/lib/R/site-library \
  && chmod -R g+w ${TINYTEX_DIR} \
  && chmod -R g+wx "${TINYTEX_DIR}/bin" \
  && echo "PATH=${PATH}" >> /usr/lib/R/etc/Renviron \
## Install kallisto
  && cd /tmp \
  && git clone https://github.com/pachterlab/kallisto.git \
  && cd kallisto \
  && git checkout -b ${KALLISTO_VERSION} \
  && mkdir build; cd build \
  && cmake .. \
  && make \
  && make install \
## Setup non-root user and groups
## First remove the docker user created by r-apt
&& userdel -r docker \
&& useradd --create-home --shell /bin/bash $CARTE_USER \
&& echo "$CARTE_USER:$CARTE_PASSWORD" | chpasswd \
&& adduser $CARTE_USER staff \
## Set up S6-overlay init system
  && wget --no-verbose -S -P /tmp/ https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/s6-overlay-amd64.tar.gz \
  && tar xzf /tmp/s6-overlay-amd64.tar.gz -C / \
## Install z.sh directory navigation utility
  && wget --no-verbose -S https://raw.githubusercontent.com/rupa/z/master/z.sh \
          -O /etc/profile.d/z.sh \
## Clean up source install
  && cd / \
  && chmod +x /entrypoint.sh \
  && rm -rf /tmp/* \
  && apt-get autoremove -y \
  && apt-get autoclean -y \
  && rm -rf /var/lib/apt/lists/*

#USER $CARTE_USER

VOLUME ["$VOLUME_PATH"]

# s6-overlay
ENTRYPOINT ["/init"]

CMD ["su ${CARTE_USER}"]
