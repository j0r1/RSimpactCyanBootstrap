local({

    origRepos <- getOption("repos")
    defaultRepos <- "https://cran.ma.imperial.ac.uk/"
    packagesUrl <- "https://raw.githubusercontent.com/j0r1/RSimpactCyanBootstrap/master/packages.csv"
    
    tryCatch({

        # If no default CRAN repo has been provided, use a specific mirror
        x <- getOption("repos")
        if (!is.element("CRAN", x)) { 
            x["CRAN"] = defaultRepos
        } else {
            if (x["CRAN"] == "@CRAN@") { # Use a default repository instead, this value would prompt user interaction
                x["CRAN"] = defaultRepos
            }
        }
        
        options(repos = x)

        installPackageOrGitHub <- function(packageInfo, name) {
            gn <- packageInfo[[name]]$github
            if (gn == "no") {
                install.packages(name)
            } else {
                devtools::install_github(gn)
            }
        }

        # Helper function to install specified packages
        installPackages <- function(packageInfo) {
    
            for (name in names(packageInfo)) {
                tryCatch({ 
                    library(name, character.only=TRUE)
                    vPack <- toString(packageVersion(name))
                    vNeeded <- packageInfo[[name]]$version
    
                    message("Version for ", name, " is ", vPack, ", needed version is ", vNeeded)
                    if (utils::compareVersion(vPack, vNeeded) < 0) {
                        message("Package ", name, " is outdated, updating")
                        unloadNamespace(name) # unload it first, otherwist R may want to be restarted

                        installPackageOrGitHub(packageInfo, name)
                    }
                }, error = function(e) { # We're assuming that it can't be loaded because it doesn't exist
                    print(e)
                    message("Installing package ", name, " for the first time")
                    installPackageOrGitHub(packageInfo, name)
                })
                library(name, character.only=TRUE)
            }
        }
    
        conn <- url(packagesUrl)
        csvInfo <- read.csv(text = readLines(conn))
        close(conn)

        packageInfo <- list()
    
        packageInfo[["devtools"]] <- list(version="1.13.6", github="no")
        for (i in 1:nrow(csvInfo)) {
            n <- toString(csvInfo$Name[[i]])
            v <- toString(csvInfo$Version[[i]])
            g <- toString(csvInfo$GitHub[[i]])

            packageInfo[[n]] <- list(version=v, github=g)
        }
    
        installPackages(packageInfo)
    }, finally =  {
        # Restore the original repository settings
        options(repos = origRepos)
    })
})

