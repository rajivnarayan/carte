## Install binary R arrow package https://arrow.apache.org/docs/r/articles/install.html
DIST_VER='focal'
options(HTTPUserAgent = sprintf("R/%s R (%s)",
				getRversion(),
				paste(getRversion(),
				      R.version["platform"], 
				      R.version["arch"], 
				      R.version["os"])
				)
)

install.packages("arrow", 
		 repos = sprintf("https://packagemanager.rstudio.com/all/__linux__/%s/latest", DIST_VER))
