local({

    origRepos <- getOption("repos")
    ownRepos <- "http://research.edm.uhasselt.be/jori"
    defaultRepos <- "https://cran.ma.imperial.ac.uk/"
    packagesUrl <- "https://raw.githubusercontent.com/j0r1/RSimpactCyanBootstrap/master/packages.csv"
    
    tryCatch({

        # Add own repository to the list, and if no default CRAN
        # repo has been provided, use a specific mirror
        x <- getOption("repos")
        if (!is.element("CRAN", x)) { 
            x["CRAN"] = defaultRepos
        } else {
            if (x["CRAN"] == "@CRAN@") { # Use a default repository instead, this value would prompt user interaction
                x["CRAN"] = defaultRepos
            }
        }
        
        x["SimpactCyan"] <- "http://research.edm.uhasselt.be/jori"
        options(repos = x)

        # Helper function to install specified packages
        installPackages <- function(packageInfo) {
    
            for (name in names(packageInfo)) {
                tryCatch({ 
                    library(name, character.only=TRUE)
                    vPack <- toString(packageVersion(name))
                    vNeeded <- packageInfo[[name]]
    
                    message("Version for ", name, " is ", vPack, ", needed version is ", vNeeded)
                    if (utils::compareVersion(vPack, vNeeded) < 0) {
                        message("Package ", name, " is outdated, updating")
                        install.packages(name)
                    }
                }, error = function(e) { # We're assuming that it can't be loaded because it doesn't exist
                    print(e)
                    message("Installing package ", name, " for the first time")
                    install.packages(name)
                })
                library(name, character.only=TRUE)
            }
        }
    
        packageInfo <- list()
        packageInfo[["RCurl"]] <- "0.0.0"
        installPackages(packageInfo)
        
        library(RCurl)
        csvInfo <- read.csv(text = getURL(packagesUrl))
        packageInfo <- list()
    
        for (i in 1:nrow(csvInfo)) {
            n <- toString(csvInfo$Name[[i]])
            v <- toString(csvInfo$Version[[i]])
            packageInfo[[n]] <- v
        }
    
        installPackages(packageInfo)
    }, finally =  {
        # Restore the original repository settings
	options(repos = origRepos)
    })
})

