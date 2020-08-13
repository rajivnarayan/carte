# carte-r 

### <u>C</u>ontainer based <u>A</u>nalysis <u>R</u>un <u>T</u>ime <u>E</u>nvironment for <u>R</u>

carte-r provides a customizable Docker container for data analysis using the R programming language.

#### Motivation

This project grew out of a need to run various scientific-computing and data-science workflows in R across multiple hosts in a reproducible manner. In particular the requirements were:

* support for a configurable and feature-rich computational environment frequently needed to process and explore real-world data
* an IDE for exploratory data analysis and developing and testing R code
* the ability to quickly expose custom algorithms via APIs for enabling web applications


#### Features

carte-r is a single Docker image that provides command-line access to a customized R environment with the ability to enable additional software components (like rstudio, opencpu and shiny) at runtime.

The image integrates several software components developed by others:

* The R analysis environment is based on the r-apt image from the [rocker project](https://github.com/rocker-org/rocker)

  * The image includes a version specific R installation with 200+ packages from CRAN and Bioconductor focused primarily on computational biology, data analysis and report generation.

  * In addition pre-configured CRAN and the marutter PPA repositories provide easy access to to over 4000+ pre-compiled binary versions of most frequently employed R packages

* Several additional services that can be optionally enabled at runtime based on :
  * Browser based IDE for R development via [Rstudio Server]()
  * [OpenCPU](https://www.opencpu.org/) server to create HTTP based API 
  * [Shiny](https://rstudio.com/products/shiny/shiny-server/) server to serve R-based interactive web applications

* The [s6-overlay](https://github.com/just-containers/s6-overlay) init system to manage multiple processes in a single container

#### Usage

##### Using the docker command

* Start a container with just R + packages and mount the host $HOME folder at /work within the container

`docker run -v $HOME:/work -it -e 'PASSWORD=changeme:)' -e 'USERID=$UID' --rm quay.io/rajivnarayan/carte-r:latest /bin/bash `

* Start r-studio server

`docker run -p 8787:8787 -p 3838:3838 -p 8080:80 -v $HOME:/work -it -e 'PASSWORD=letmein:)' -e ADD_RSTUDIO=true -e SUDO=true -e USERID=$UID --rm quay.io/rajivnarayan/carte-r:latest /bin/bash`

##### Using docker-compose

* Initial setup
	* Clone this repo and change 

	`cd carte/carte-r`

	* Copy the dotenv file to .env and change the variables as needed

	`cp dotenv to .env`

* Start a base container with command-line access

`docker-compose run base`

Type `R` to start the R interpreter

* Start a full-fledged container with Rstudio and opencpu

`docker-compose up full`

Access Rstudio by visting http://localhost:8787 in a web browser (change the port to $RSTUDIO_HOST_PORT if changed in the .env file)

Access OpenCpu http://localhost:8080/ocpu or the value of $OPENCPU_HTTP_PORT in the .env file

##### Building an image using the Docker file

`docker build --no-cache=true --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') --build-arg BUILD_VERSION="test" -t carte-r:latest`

#### Docker Environment variables

- `PASSWORD`: **Required**, sets the carte user password at runtime 
- `SUDO`: Adds carte user to sudoers file if true, Default is false
- `USERID`: Sets the UID of the user, default is 1000
- `GROUPID`: Sets the GID, default is 1000
- `ADD_RSTUDIO`: Install R-Studio Server within the container if true. Default is false
- `ADD_OPENCPU`: Install OpenCPU if true. Default is false
- `ADD_SHINY`: Install Shiny serever if true. Default is false

#### Container ports
Services if enabled run on the following ports within the container:

- `RSTUDIO_PORT=8787`
- `SHINY_PORT=3838`
- `OPENCPU_HTTP_PORT=80`
- `OPENCPU_HTTPS_PORT=443`

