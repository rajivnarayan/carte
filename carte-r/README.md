# carte-r 

### <u>C</u>ontainer based <u>A</u>nalysis <u>R</u>un <u>T</u>ime <u>E</u>nvironment for <u>R</u>

carte-r provides a customizable Docker container for data analysis using the R programming language.

#### Motivation

This project grew out of a need to run different scientific-computing and data-science workflows in R across multiple hosts in a reproducible manner. In particular the requirements were:

* support for configurable and feature-rich computational environments frequently needed to process and explore real-world data
* an IDE for developing and testing R code
* a stable and cross-platform method for deploying custom algorithms and computational workflows
*  the ability to quickly expose custom algorithms via APIs for enabling web applications

Why not just rocker

#### Features

The carte-r image integrates several software components developed by others:

* R analysis environment based on the r-apt image from the [rocker project](https://github.com/rocker-org/rocker)

  The image includes R-3.6 and 200+ packages from CRAN and Bioconductor focused primarily on computational biology, data analysis and report generation.

  In addition pre-configured CRAN and the marutter repositories provide easy access to to over 4000+ binary versions of most frequently employed R packages

* Several additional services that can be optionally enabled at runtime based on :
  * Browser based IDE for R development via [Rstudio Server]()
  * [OpenCPU](https://www.opencpu.org/) server to create HTTP based API 
  * [Shiny](https://rstudio.com/products/shiny/shiny-server/) server to serve R-based interactive web applications

* The [s6-overlay](https://github.com/just-containers/s6-overlay) init system to manage multiple processes in a single container

#### Usage

##### Starting containers using docker

Start a container with just R + packages and mount the users home folder at /work

`docker run -v $HOME:/work -it -e 'PASSWORD=changeme:)' -e 'USERID=$UID' --rm quay.io/rajivnarayan/carte-r:latest /bin/bash `

Start r-studio server

`docker run -p 8787:8787 -p 3838:3838 -p 8080:80 -v $HOME:/work -it -e 'PASSWORD=letmein:)' -e ADD_RSTUDIO=true -e SUDO=true -e USERID=$UID --rm quay.io/rajivnarayan/carte-r:latest /bin/bash`



##### Starting containers using docker-compose

Clone this repo and 

`cd carte/carte-r`

Inspect and change the variables in the .env file

Start a basic container with command-line access

`docker-compose run base su carte`

Type `R` to start the R interpreter

`pkg=installed.packages(priority="NA")[,c(1,3)]; prmatrix(pkg, rowlab=rep("", nrow(pkg)))`

Start a full-fledged container with Rstudio and opencpu

`docker-compose up full`

Access Rstudio by visting http://localhost:8787 in a web browser (change the port to $RSTUDIO_PORT if changed in the .env file)

Access OpenCpu http://localhost:8080/ocpu or the value of $OPENCPU_HTTP_PORT in the .env file



Building an image using the Docker file

`docker build --no-cache=true --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') --build-arg BUILD_VERSION="test" -t carte-r:latest`

Customizing

#### Implementation Details

based on rocker/r-apt image
access to pre-build binary R packages

s6 init system

services
runtime user configuration

Change username from carte
docker run -e CARTE_USER=<myname>

Set password at runtime from default
docker run -e CARTE_PASSWORD=<mypassword>

Allow sudo root access
-e SUDO=TRUE

USERID
GROUPID
UMASK

R
Packages - 
tidyverse
cmapR
kallisto