## be sure to update the 'Package Options' section of the package help file
##   in R/spades-core-package.R
##
# e = new.env()
#
# reg.finalizer(e, function(e) {
#   message('Object Bye!')
# }, onexit = TRUE)
#
#
# finalize <- function(env) {
#   print(ls(env))
#   message("Bye from Name space Finalizer")
# }

.spadesTempDir <- function() {
  file.path(tempdir(), "SpaDES")
}

.onLoad <- function(libname, pkgname) {
  ## set options using the approach used by devtools
  opts <- options()
  reproCachePath <- getOption("reproducible.cachePath")
  opts.spades <- spadesOptions()
  toset <- !(names(opts.spades) %in% names(opts))
  if (any(toset)) options(opts.spades[toset])

  # table of equivalent time conversions of first 1e4 integers, in seconds
  .pkgEnv[["nUnitConversions"]] <- 1e4L
  bb <- 0:.pkgEnv[["nUnitConversions"]]
  bbs <- list()
  for (u in .spadesTimes) {
    bbs[[u]] <- bb
    attr(bbs[[u]], "unit") <- u
    bbs[[u]] <- round(as.numeric(convertTimeunit(bbs[[u]], "seconds", skipChecks = TRUE)), 0)
  }
  .pkgEnv[["unitConversions"]] <- as.matrix(as.data.frame(bbs))

  # module template path
  .pkgEnv[["templatePath"]] <- system.file("templates", package = "SpaDES.core")

  # Create active binding for "Paths"
  pkgEnv <- parent.env(environment())
  rm("Paths", envir = pkgEnv)
  makeActiveBinding(sym = "Paths", fun = function() .paths(), env = pkgEnv)

  # parent <- parent.env(environment())
  # print(str(parent))
  # reg.finalizer(parent, finalize, onexit= TRUE)

  invisible()
}

#' @importFrom utils packageVersion
.onAttach <- function(libname, pkgname) {
  if (interactive()) {
    packageStartupMessage("Using SpaDES.core version ", utils::packageVersion("SpaDES.core"), ".")
    a <- capture.output(setPaths(), type = "message")
    a <- paste(a, collapse = "\n")
    packageStartupMessage(a)
    packageStartupMessage(
      "To change these, use setPaths(...); see ?setPaths"
    )
    packageStartupMessage(
      "See ?spadesOptions for advanced features"
    )
  }

  # unlockBinding("Paths", as.environment("package:SpaDES.core"))
  # rm("Paths", envir = as.environment("package:SpaDES.core"))
  # makeActiveBinding(sym = "Paths",
  #                   fun = function() {
  #                     SpaDES.core:::.paths()
  #                   },
  #                   env = as.environment("package:SpaDES.core")
  #                   #env = environment()#"package:SpaDES.core")
  # )
  # #lockBinding("Paths", as.environment("package:SpaDES.core"))

  # rm("Paths", envir = as.environment("package:SpaDES.core"))
  # makeActiveBinding(sym = "Paths",
  #                   fun = function() {
  #                     .paths()
  #                   },
  #                   env = as.environment("package:SpaDES.core")
  # )
  # lockBinding("Paths", as.environment("package:SpaDES.core"))
}

.onUnload <- function(libpath) {
  ## if temp session dir is being used, ensure it gets reset each session
  #if (.getOption("spades.cachePath") == file.path(.spadesTempDir(), "cache")) {
  #  options(spades.cachePath = NULL)
  #}
  if (getOption("spades.inputPath") == file.path(.spadesTempDir(), "inputs")) {
    options(spades.inputPath = NULL)
  }
  if (all(getOption("spades.modulePath") %in% file.path(.spadesTempDir(), "modules"))) {
    options(spades.modulePath = NULL)
  }
  if (getOption("spades.outputPath") == file.path(.spadesTempDir(), "outputs")) {
    options(spades.outputPath = NULL)
  }
}
