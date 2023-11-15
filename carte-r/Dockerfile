# CARTE-R A Container based Analysis RunTime Environment for R
#
#
# Based on the Rocker r-ubuntu image
# https://rocker-project.org/images/other/r-ubuntu.html
# https://github.com/rocker-org/ubuntu-lts
#
# docker build --no-cache=true --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') --build-arg BUILD_VERSION="test" -t carte-r:latest .

FROM rocker/r-ubuntu:focal

ARG BUILD_DATE
ARG BUILD_VERSION="latest"
# non-root user
# Change using --build-arg CARTE_USER='myname"
ARG CARTE_USER='carte'
# Change using --build-arg CARTE_PASSWORD="mypassword"
ARG CARTE_PASSWORD='carte:)'

# Mountpont for externally mounted volume
ARG VOLUME_PATH="/work"

# R config options
ARG R_VERSION="4.2"
ARG BIOCONDUCTOR_VERSION="3.16"

# Rstudio options
# operating system, should ideally match the base image
ENV RSTUDIO_OS=${RSTUDIO_OS:-focal}
# specific version
ENV RSTUDIO_VERSION=${RSTUDIO_VERSION:-latest}

#SPARK options
ENV SPARK_VERSION=3.1

# Path to User installed libraries
ARG R_SITE_LIBRARY_PATH="/usr/local/lib/R/site-library"

# S6 process supervisor options
ARG S6_VERSION
ENV S6_VERSION=${S6_VERSION:-v2.2.0.1}
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2
# divert signals from PID1 to CMD
ENV S6_CMD_RECEIVE_SIGNALS=1

# Kallisto options
ARG KALLISTO_VERSION="v0.46.1"

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
# copy packages to tmp location
COPY pkg /tmp/pkg

## Install system dependencies
RUN add-apt-repository ppa:cran/libgit2 \
  && apt-get update \
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
  hdf5-tools \
  seqtk \
  samtools \
  bowtie2 \
 ## system library dependencies
  ## cytolib dependency
  libboost-filesystem-dev \
  libcairo2-dev \
  libcurl4-openssl-dev \
  libgit2-dev \
  libhdf5-103 \
  libhdf5-dev \
  libmariadbd-dev \
  libmariadb-dev-compat \
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
  ## Python3 high-throughput genome sequencing read analysis utilities
  python3-htseq \
  python3-pip \
  ## R CMD Check wants qpdf to check pdf sizes, or throws a Warning
  qpdf \
  ## For building PDF manuals
  texinfo \
  ## parallelization
  libzmq3-dev \
  libopenmpi-dev \
  default-jre-headless \
  # Binary R packages
  # provides r-api
  r-base-core \
  # provides r-api-bioc
  r-bioc-biocgenerics \
  r-cran-arules \
  r-cran-base64enc \
  r-cran-bigrquery \
  r-cran-biocmanager \
  r-cran-bitops \
  r-cran-caret \
  r-cran-catools \
  r-cran-circlize \
  r-cran-clustermq \
  r-cran-curl \
  r-cran-data.table \
  r-cran-dbscan \
  #r-bioc-delayedarray \
  r-cran-dendextend \
  r-cran-devtools \
  r-cran-doparallel \
  r-cran-dplyr \
  r-cran-dt \
  r-bioc-edger \
  r-cran-egg \
  r-cran-e1071 \
  r-cran-eulerr \
  r-cran-fastcluster \
  r-cran-foreach \
  r-cran-formatr \
  r-cran-futile.logger \
  r-bioc-genomicranges \
  r-bioc-genomeinfodb \
  r-bioc-genomeinfodbdata \
  r-bioc-genefilter \
  r-bioc-geoquery \
  r-cran-gert \
  r-cran-ggally \
  #r-cran-ggbeeswarm \
  r-cran-ggridges \
  r-cran-gghighlight \
  r-cran-ggplot2 \
  r-cran-ggpubr \
  r-cran-ggrepel \
  r-cran-glmnet \
  r-cran-gridextra \
  r-cran-gsubfn \
  r-cran-gt \
  r-cran-gtable \
  r-cran-ggvis \
  r-cran-here \
  r-cran-highr \
  r-cran-hmisc \
  r-cran-htmltools \
  r-cran-httr \
  r-cran-huxtable \
  r-cran-ineq \
  r-cran-igraph \
  r-cran-jsonlite \
  r-cran-knitr \
  r-bioc-limma \
  r-cran-mlmetrics \
  r-cran-markdown \
  r-cran-microbenchmark \
  r-cran-mvtnorm \
  r-cran-paws \
  r-cran-patchwork \
  r-cran-pcapp \
  r-cran-pheatmap \
  r-cran-plotly \
  r-cran-processx \
  r-cran-rpostgres \
  r-cran-psych \
  r-bioc-qvalue \
  r-cran-ranger \
  r-cran-rattle \
  r-cran-rcolorbrewer \
  r-bioc-rhdf5lib \
  r-bioc-rhdf5 \
  r-cran-remotes \
  r-cran-rmarkdown \
  r-cran-rprojroot \
  r-cran-rrcov \
  r-cran-rtsne \
  r-cran-selectr \
  r-cran-seqinr \
  r-cran-seurat \
  r-bioc-singscore \
  r-cran-skimr \
  r-cran-statmod \
  #r-cran-statmodel \
  #r-bioc-summarizedexperiment \
  #r-cran-sparklyr \
  r-cran-targets \
  r-cran-tidyverse \
  r-cran-testthat \
  r-cran-r.utils \
  r-cran-usethis \
  r-cran-venndiagram \
  r-cran-wgcna \
  r-cran-xaringan \
  r-cran-xgboost \
  r-cran-xml2 \
  r-cran-yaml \
  ## toolkit for processing next-gen sequencing data
  subread" \
  && apt-get install -y --no-install-recommends $BUILD_DEPS \
# Install AWS CLI latest
  && mkdir -p /tmp/awscli \
  && cd /tmp/awscli \
  && wget -qO awscli.zip 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' \
  && unzip awscli.zip \
  && ./aws/install \
## Hugo
  && wget -qO /tmp/hugo.deb https://github.com/gohugoio/hugo/releases/download/v0.80.0/hugo_0.80.0_Linux-64bit.deb \
  && dpkg -i /tmp/hugo.deb \
## Install missing R packages from CRAN and Bioconductor
  && install2.r --skipinstalled \
   --repos "http://bioconductor.org/packages/${BIOCONDUCTOR_VERSION}/bioc" \
   --repos "https://cloud.r-project.org" \
   'apeglm' \
   'argparser' \
   'ashr' \
   'flowCore' \
   'cmapR' \
   'GetoptLong' \
   'GSVA' \
   'ggsurvfit' \
   'ggvenn' \
   'ggvenndiagram' \
   'ComplexHeatmap' \
   'maftools' \
   'noctua' \
   'prada' \
   'Rsubread' \
   'sva' \
   'DESeq2' \
   'Glimma' \
   'tximport' \
   'biomaRt' \
   'flexdashboard' \
   'uwot' \
   'ggbump' \
   'ggbeeswarm' \
   'sparklyr' \
   'ggrastr' \
   'tryCatchLog' \
   'jinjar' \
   'inspectdf' \
## copy/paste utility
   && install2.r --repos 'https://milesmcbain.r-universe.dev' 'datapasta' \
## Install SRA toolkit
  && wget -qO/tmp/setup-apt.sh https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/3.0.2/setup-apt.sh \
  && /bin/sh /tmp/setup-apt.sh \
## Install packages from Github, fails due to API limits, using local install
## gastonstat/arcdiagram, jcheng5/crosstalk, jcheng5/d3scatter
  && find '/tmp/pkg' -name '*.zip' | while read pkg; do install2.r --error $pkg; done \
## Use tinytex for LaTeX installation
  && install2.r --error tinytex \
  ## Admin-based install of TinyTeX:
  && wget -qO- \
    "https://yihui.org/tinytex/install-unx.sh" | \
    TINYTEX_DIR=${TINYTEX_DIR} sh -s - --admin --no-path \
  && ${TINYTEX_DIR}/bin/*/tlmgr path add \
  && tlmgr install ae inconsolata listings metafont mfware parskip pdfcrop tex \
  && tlmgr path add \
  && Rscript -e "tinytex::r_texmf()" \
  && chown -R root:staff ${TINYTEX_DIR} \
  && chown -R root:staff /usr/local/lib/R/site-library \
  && chmod -R g+w ${TINYTEX_DIR} \
  && chmod -R g+wx "${TINYTEX_DIR}/bin" \
# Setup non-root user and groups
## First remove the docker user created by r-apt
&& userdel -r docker \
&& useradd --create-home --shell /bin/bash $CARTE_USER \
&& echo "$CARTE_USER:$CARTE_PASSWORD" | chpasswd \
&& adduser $CARTE_USER staff \
## Set up S6-overlay init system
  && wget --no-verbose -S -P /tmp/ https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/s6-overlay-amd64-installer \
  && chmod +x /tmp/s6-overlay-amd64-installer \
  && /tmp/s6-overlay-amd64-installer / \
## Install z.sh directory navigation utility
  && wget --no-verbose -S https://raw.githubusercontent.com/rupa/z/master/z.sh \
          -O /etc/profile.d/z.sh \
## Install spark
  && Rscript -e "library(sparklyr); spark_install('${SPARK_VERSION}');" \
## Install binary R arrow package (https://arrow.apache.org/docs/r/articles/install.html)
&& Rscript '/tmp/pkg/install_arrow.R' \
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

CMD ["su", "${CARTE_USER}"]
