# CARTE-PY A Container based Analysis RunTime Environment for Python
#
# docker build --no-cache=true --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') --build-arg BUILD_VERSION="test" -t carte-py:latest .

FROM continuumio/miniconda3:4.6.14

ARG BUILD_DATE
ARG BUILD_VERSION="latest"
# non-root user 
# Change using --build-arg CARTE_USER='myname" 
ENV CARTE_USER='carte'
# Change using --build-arg CARTE_PASSWORD="mypassword"
ARG CARTE_PASSWORD='carte:)'

# disable .pyc generation
ENV PYTHONDONTWRITEBYTECODE=true
# enable traceback on segfaults
ENV PYTHONFAULTHANDLER=1
# S6 process supervisor options
ARG S6_VERSION
ENV S6_VERSION=${S6_VERSION:-v1.21.7.0}
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2

LABEL org.label-schema.name="carte-py" \
	  org.label-schema.description="CARTE-PY is a container image that provides runtime environment for data analysis using the Python programming language" \
	  org.label-schema.version="$BUILD_VERSION" \
	  org.label-schema.build-date="$BUILD_DATE" \
	  org.label-schema.license="GPL-2.0" \
      org.label-schema.vcs-url="https://github.com/rajivnarayan/carte/carte-py" \
      org.label-schema.schema-version="1.0"

 # copy config files
COPY root /
    
RUN \
    #---------------------
    ## Setup non-root user
    #---------------------
    useradd --create-home --shell /bin/bash $CARTE_USER \
	&& echo "$CARTE_USER:$CARTE_PASSWORD" | chpasswd \
	&& adduser $CARTE_USER staff \
	#-------------------------
	## Setup conda environment
	#-------------------------
	&& conda create --prefix /home/$CARTE_USER/conda_env/py3 python=3.7 \
	&& conda install --prefix /home/$CARTE_USER/conda_env/py3 --yes --freeze-installed \
    nomkl \
    dask==1.2.2 \
    numpy==1.16.3 \
    pandas==0.24.2 \
    tini==0.18.0 \
    && conda clean -afy \
    #&& find /opt/conda/ -follow -type f -name '*.a' -o \
    # -name '*.pyc' -o -name '*.js.map' -delete \
    #&& find /opt/conda/lib/python*/site-packages/bokeh/server/static \
    #-follow -type f -name '*.js' ! -name '*.min.js' -delete \
	#-------------------------------
    ## Set up S6-overlay init system
    #-------------------------------
	&& wget --no-verbose -S -P /tmp/ https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/s6-overlay-amd64.tar.gz \
	&& tar xzf /tmp/s6-overlay-amd64.tar.gz -C / \
	#------------------------
    ## Clean up source install
    #-------------------------
	&& cd / \
	&& rm -rf /tmp/* \
	&& apt-get autoremove -y \
	&& apt-get autoclean -y \
	&& rm -rf /var/lib/apt/lists/*

#ENTRYPOINT ["tini", "-g", "--"]

# s6-overlay
ENTRYPOINT ["/init"]

CMD ["su ${CARTE_USER}"]
