temporarySimpactCyanInstallFunctionName <- function() {

    ownRepos <- "http://research.edm.uhasselt.be/jori"
    defaultRepos <- getOption("repos")[["CRAN"]]
    if (defaultRepos == "@CRAN@") {
        defaultRepos <- "https://cran.ma.imperial.ac.uk/"
    }

    packageInfo <- list()
    packageInfo[["RJSONIO"]] <- c(defaultRepos, "1.3.0")
    packageInfo[["findpython"]] <- c(defaultRepos, "1.0.1")
    packageInfo[["rPithon"]] <- c(ownRepos, "1.1.1")
    packageInfo[["RSimpactCyan"]] <- c(ownRepos, "1.4.0")

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

temporarySimpactCyanInstallFunctionName()
temporarySimpactCyanInstallFunctionName <- NULL
