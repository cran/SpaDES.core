utils::globalVariables(c("fun", "loadTime", "package"))

#' File extensions map
#'
#' How to load various types of files in R.
#'
#' @export
#' @rdname loadFiles
.fileExtensions <- function() {
  .fE <- data.frame(matrix(ncol = 3, byrow = TRUE, c(
    "asc", "raster", "raster",
    "csv", "read.csv", "utils",
    "png", "raster", "raster",
    "qs", "qread", "qs",
    "Rdata", "load", "base",
    "rdata", "load", "base",
    "RData", "load", "base",
    "rds", "readRDS", "base",
    "RDS", "readRDS", "base",
    "shp", "readOGR", "rgdal",
    "tif", "raster", "raster",
    "txt", "read.table", "utils"
    )),
    stringsAsFactors = FALSE)
  colnames(.fE) <- c("exts", "fun", "package")
  return(.fE)
}

#' Extract filename (without extension) of a file
#'
#' @param x  List or character vector
#'
#' @return A character vector.
#'
#' @author Eliot McIntire
fileName <- function(x) {
  return(unlist(strsplit(basename(unlist(x)), "\\..*$")))
}

# The load doEvent
doEvent.load <- function(sim, eventTime, eventType, debug = FALSE) { # nolint
  if (eventType == "inputs") {
    sim <- loadFiles(sim)
  }
  return(invisible(sim))
}

###############################################################################
#' Load simulation objects according to \code{filelist}
#'
#' This function has two roles: 1) to proceed with the loading of files that
#' are in a simList or 2) as a short cut to simInit(inputs = filelist). Generally
#' not to be used by a user.
#'
#' @seealso \code{\link{inputs}}
#'
#' @param sim      \code{simList} object.
#'
#' @param filelist \code{list} or \code{data.frame} to call \code{loadFiles} directly from the
#'                  \code{filelist} as described in Details
#'
#' @param ...      Additional arguments.
#'
#' @author Eliot McIntire and Alex Chubaty
#' @export
#' @importFrom data.table := data.table rbindlist
#' @importFrom raster inMemory
#' @importFrom utils getFromNamespace
#' @include simulation-simInit.R
#' @name loadFiles
#' @rdname loadFiles
#'
#' @examples
#' \dontrun{
#'
#' # Load random maps included with package
#' filelist <- data.frame(
#'     files = dir(system.file("maps", package = "quickPlot"),
#'             full.names = TRUE, pattern = "tif"),
#'     functions = "rasterToMemory", package = "quickPlot"
#' )
#' sim1 <- loadFiles(filelist = filelist)
#' clearPlot()
#' if (interactive()) Plot(sim1$DEM)
#'
#' # Second, more sophisticated. All maps loaded at time = 0, and the last one is reloaded
#' #  at time = 10 and 20 (via "intervals").
#' # Also, pass the single argument as a list to all functions...
#' #  specifically, when add "native = TRUE" as an argument to the raster function
#' files = dir(system.file("maps", package = "quickPlot"),
#'             full.names = TRUE, pattern = "tif")
#' arguments = I(rep(list(native = TRUE), length(files)))
#' filelist = data.frame(
#'    files = files,
#'    functions = "raster::raster",
#'    objectName = NA,
#'    arguments = arguments,
#'    loadTime = 0,
#'    intervals = c(rep(NA, length(files)-1), 10)
#' )
#'
#' sim2 <- loadFiles(filelist = filelist)
#'
#' # if we extend the end time and continue running, it will load an object scheduled
#' #  at time = 10, and it will also schedule a new object loading at 20 because
#' #  interval = 10
#' end(sim2) <- 20
#' sim2 <- spades(sim2) # loads the percentPine map 2 more times, once at 10, once at 20
#' }
setGeneric("loadFiles", function(sim, filelist, ...)  {
  standardGeneric("loadFiles")
})

#' @rdname loadFiles
setMethod(
  "loadFiles",
  signature(sim = "simList", filelist = "missing"),
  definition = function(sim, ...) {
    # Pull .fileExtensions() into function so that scoping is faster
    .fileExts <- .fileExtensions()

    if (NROW(inputs(sim)) != 0) {
      inputs(sim) <- .fillInputRows(inputs(sim), start(sim))
      filelist <- inputs(sim) # does not create a copy - because data.table ... this is a pointer
      nonNAFileList <- filelist[!is.na(filelist$file),]
      if (NROW(nonNAFileList)) {
        doFilesExist <- file.exists(nonNAFileList$file)
        if (any(!doFilesExist)) {
          stop("These files in 'inputs' don't exist; please put them in the right place, ",
             "or change `inputs`:\n    ",
             paste0(nonNAFileList$file[!doFilesExist], collapse = "\n    "))
        }
      }

      curTime <- time(sim, timeunit(sim))
      arguments <- inputArgs(sim)
      # Check if arguments is a named list; the name may be concatenated
      # with the "arguments", separated by a ".". This will extract that.
      if ((length(arguments) > 0) & !is.null(names(arguments))) {
        if (grepl(".", fixed = TRUE, names(filelist)[pmatch("arguments", names(filelist))]))
          names(arguments) <- sapply(strsplit(
            names(filelist)[pmatch("arguments", names(filelist))], ".", fixed = TRUE),
            function(x) x[-1]
          )
      }

      # check if arguments should be, i.e,. recycled
      if (!is.null(arguments)) {
        if (length(arguments) < length(filelist$file)) {
          arguments <- rep(arguments, length.out = length(filelist$file))
        }
      }

      # only load those that are to be loaded at their loadTime
      cur <- (filelist$loadTime == curTime) & !(sapply(filelist$loaded, isTRUE))

      if (any(cur)) {
        # load files
        loadPackage <- filelist$package
        loadFun <- filelist$fun
        for (y in which(cur)) {
          nam <- names(arguments[y])
          if (is.na(filelist$file[y])) {
            # i.e., only for objects
            if (!is.na(loadFun[y])) {
              if (is.na(loadPackage[y])) {
                if (exists(loadFun[y])) {
                  objList <- list(do.call(get(loadFun[y]), arguments[[y]]))
                } else {
                  stop("'inputs' often requires (like now) that package be specified",
                       " explicitly in the 'fun' column, e.g., base::load")
                }
              } else {
                objList <- list(do.call(getFromNamespace(loadFun[y], loadPackage[y]), arguments[[y]])) # nolint
              }
            } else {
              objListEnv <- quickPlot::whereInStack(filelist$objectName[y])
              objList <- list(get(filelist$objectName[y], objListEnv))
            }
            names(objList) <- filelist$objectName[y]
            if (length(objList) > 0) {
              list2env(objList, envir = sim@.xData)
              filelist[y, "loaded"] <- TRUE
              message(filelist[y, "objectName"], " loaded into simList")
            } else {
              message("Can't find object '", filelist$objectName[y], "'. ",
                      "To correctly transfer it to the simList, it should be ",
                      "in the search path.")
            }
          } else {
            # for files
            if (is.na(loadPackage[y])) {
              if (!exists(loadFun[y])) {
                stop("'inputs' often requires (like now) that package be specified",
                     " explicitly in the 'fun' column, e.g., base::load")
              }
            }
            if (!is.null(nam)) {
              argument <- list(unname(unlist(arguments[y])), filelist[y, "file"])
              if (is.na(loadPackage[y])) {
                names(argument) <- c(nam, names(formals(get(loadFun[y])))[1])
              } else {
                names(argument) <- c(nam, names(formals(getFromNamespace(loadFun[y], loadPackage[y])))[1])
              }

            } else {
              argument <- list(filelist[y, "file"])
              if (is.na(loadPackage[y])) {
                names(argument) <- names(formals(get(loadFun[y])))[1]
              } else {
                names(argument) <- names(formals(getFromNamespace(loadFun[y], loadPackage[y])))[1]
              }
            }

            # The actual load call
            if (identical(loadFun[y], "load")) {
              do.call(getFromNamespace(loadFun[y], loadPackage[y]),
                      args = argument, envir = sim@.xData)
            } else {
              sim[[filelist[y, "objectName"]]] <-
                if (is.na(loadPackage[y])) {
                  do.call(get(loadFun[y]), args = argument)
                } else {
                  do.call(getFromNamespace(loadFun[y], loadPackage[y]),
                          args = argument)
                }
            }
            filelist[y, "loaded"] <- TRUE

            if (loadFun[y] == "raster") {
              message(paste0(
                filelist[y, "objectName"], " read from ", filelist[y, "file"], " using ", loadFun[y], # nolint
                "(inMemory=", inMemory(sim[[filelist[y, "objectName"]]]), ")",
                ifelse(filelist[y, "loadTime"] != sim@simtimes[["start"]],
                       paste("\n  at time", filelist[y, "loadTime"]), "")
              ))
            } else {
              message(paste0(
                filelist[y, "objectName"], " read from ", filelist[y, "file"], " using ", loadFun[y], # nolint
                ifelse(filelist[y, "loadTime"] != sim@simtimes[["start"]],
                       paste("\n   at time", filelist[y, "loadTime"]), "")
              ))
            }
          }
        } # end y
        # add new rows of files to load based on filelistDT$Interval
        if (!is.na(match("intervals", names(filelist)))) {
          if (any(!is.na(filelist[filelist$loaded, "intervals"]))) {

            newFilelist <- filelist[(filelist$loaded & !is.na(filelist$intervals)), ]
            newFilelist[, c("loadTime", "loaded", "intervals")] <-
              data.frame(curTime + newFilelist$intervals, NA, NA_real_)
            filelist <- rbind(filelist, newFilelist)
          }
        }
      } # if there are no files to load at curTime, then nothing

      if (is(filelist, "data.frame")) {
        inputs(sim) <- filelist # this is required if intervals is used
      } else if (is(filelist, "list")) {
        inputs(sim) <- c(as.list(filelist), arguments = arguments)
      } else {
        stop("filelist must be either a list or data.frame")
      }
    }
    return(invisible(sim))
})

#' @rdname loadFiles
setMethod("loadFiles",
          signature(sim = "missing", filelist = "ANY"),
          definition = function(filelist, ...) {
            sim <- simInit(times = list(start = 0.0, end = 1),
                           params = list(),
                           inputs = filelist,
                           modules = list(), ...)
            return(invisible(sim))
})

#' @rdname loadFiles
setMethod("loadFiles",
          signature(sim = "missing", filelist = "missing"),
          definition = function(...) {
            message("no files loaded because sim and filelist are empty")
})

#######################################################
#' Read raster to memory
#'
#' Wrapper to the \code{raster} function, that creates the raster object in
#' memory, even if it was read in from file. There is the default method which is
#' just a pass through, so this can be safely used on large complex objects,
#' recursively, e.g., a \code{simList}.
#'
#' @param x An object passed directly to the function raster (e.g., character string of a filename).
#'
#' @param ... Additional arguments to \code{raster::raster}, \code{raster::stack},
#' or \code{raster::brick}.
#'
#' @return A raster object whose values are stored in memory.
#'
#' @seealso \code{\link{raster}}.
#'
#' @name rasterToMemory
#' @importFrom raster getValues raster setValues
#' @export
#' @rdname rasterToMemory
#'
#' @author Eliot McIntire and Alex Chubaty
#'
setGeneric("rasterToMemory", function(x, ...) {
  standardGeneric("rasterToMemory")
})

#' @rdname rasterToMemory
setMethod("rasterToMemory",
          signature = c(x = "Raster"),
          definition = function(x, ...) {
            if (any(nchar(Filenames(x)) > 0)) {
              r <- rasterCreate(x, ...)
              r[] <- getValues(x)
              if (is(x, "RasterStack") && !is(r, "RasterStack")) {
                r <- raster::stack(r, ...)
              }
              x <- r
            }
            return(x)
})

#' @rdname rasterToMemory
setMethod("rasterToMemory",
          signature = c(x = "list"),
          definition = function(x, ...) {
            lapply(x, rasterToMemory, ...)
})

#' @rdname rasterToMemory
setMethod("rasterToMemory",
          signature = c(x = "ANY"),
          definition = function(x, ...) {
            x
})

#' @rdname rasterToMemory
setMethod("rasterToMemory",
          signature = c(x = "simList"),
          definition = function(x, ...) {
            obj <- lapply(as.list(x), rasterToMemory, ...) # explicitly don't do hidden "." objects
            list2env(obj, envir = envir(x))
            return(x)
})


#' Simple wrapper to load any \code{Raster*} object
#' This wraps either \code{raster::raster}, \code{raster::stack},
#' or \code{raster::brick}, allowing a single function to be used
#' to create a new object of the same class as a template.
#'
#' @export
#' @param x An object, notably a \code{Raster*} object. All others will simply
#'   be passed through with no effect.
#' @param ... Passed to \code{raster::raster}, \code{raster::stack},
#' or \code{raster::brick}
#'
#' @details
#' A new (empty) object of same class as the original.
#'
rasterCreate <- function(x, ...) {
  UseMethod("rasterCreate")
}

#' @describeIn rasterCreate Simply passes through argument with no effect
rasterCreate.default <- function(x, ...) {
  x
}

#' @describeIn rasterCreate Uses \code{raster::brick}
rasterCreate.RasterBrick <- function(x, ...) {
  raster::brick(x, ...)
}

#' @describeIn rasterCreate Uses \code{raster::raster}
rasterCreate.RasterLayer <- function(x, ...) {
  raster::raster(x, ...)
}

#' @describeIn rasterCreate Uses \code{raster::stack}
rasterCreate.RasterStack <- function(x, ...) {
  raster::stack(x, ...)
}

#' @describeIn rasterCreate Uses \code{raster::raster} when one of the other,
#'   less commonly used \code{Raster*} classes, e.g., \code{RasterLayerSparse}
rasterCreate.Raster <- function(x, ...) {
  raster::raster(x, ...)
}

