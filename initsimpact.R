temporarySimpactCyanInstallFunctionName <- function() {

    packagesUrl <- "https://raw.githubusercontent.com/j0r1/RSimpactCyanBootstrap/master/packages.csv"
    ownRepos <- "http://research.edm.uhasselt.be/jori"
    defaultRepos <- getOption("repos")[["CRAN"]]
    if (defaultRepos == "@CRAN@") {
        defaultRepos <- "https://cran.ma.imperial.ac.uk/"
    }

    installPackages <- function(packageInfo) {

        for (name in names(packageInfo)) {
            tryCatch({ 
                library(name, character.only=TRUE)
                vPack <- toString(packageVersion(name))
                vNeeded <- packageInfo[[name]][2]

                message("Version for ", name, " is ", vPack, ", needed version is ", vNeeded)
                if (utils::compareVersion(vPack, vNeeded) < 0) {
                    message("Package ", name, " is outdated, updating")
                    install.packages(name, repos=packageInfo[name])
                }
            }, error = function(e) { # We're assuming that it can't be loaded because it doesn't exist
                print(e)
                message("Installing package ", name, " for the first time")
                install.packages(name, repos=packageInfo[[name]])
            })
            library(name, character.only=TRUE)
        }
    }

    packageInfo <- list()
    packageInfo[["RCurl"]] <- c(defaultRepos, "0.0.0")
    installPackages(packageInfo)
    
    library(RCurl)
    csvInfo <- read.csv(text = getURL(packagesUrl))
    packageInfo <- list()

    for (i in 1:nrow(csvInfo)) {
        n <- toString(csvInfo$Name[[i]])
        v <- toString(csvInfo$Version[[i]])
        r <- toString(csvInfo$Repository[[i]])
        if (r == "own") {
            r <- ownRepos
        } else if (r == "default") {
            r <- defaultRepos
        }
        packageInfo[[n]] <- c(r, v)
    }

    installPackages(packageInfo)
}

temporarySimpactCyanInstallFunctionName()
temporarySimpactCyanInstallFunctionName <- NULL
