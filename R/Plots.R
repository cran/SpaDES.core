#' \code{Plot} wrapper intended for use in a SpaDES module
#'
#' This is a single function call that allows a module to change which format in which
#' the plots will occur.
#' Specifically, the two primary formats would be to \code{"screen"} or to disk as an image file,
#' such as \code{"png"}.
#' \emph{THIS CURRENTLY ONLY WORKS CORRECTLY WITH \code{ggplot2} objects that can be saved.}
#' It uses \code{Plot} internally, so individual plots may be rearranged.
#' This function requires at least 2 things: a plotting function and data for that plot function.
#' See below and examples.
#'
#' @note THIS IS STILL EXPERIMENTAL and could change in the next release.
#'
#' \code{Plots} now has experimental support for "just a \code{Plot} call",
#' but with \code{types} specified.
#' See example.
#' The devices to save on disk will have some different behaviours to the screen representation,
#' since "wiping" an individual plot on a device doesn't exist for a file device.
#'
#' This offers up to 4 different actions for a given plot:
#'     \itemize{
#'       \item To screen device
#'       \item To disk as raw data
#'       \item To disk as a saved plot object
#'       \item To disk as a \file{.png} or other image file, e.g., \file{.pdf}
#'     }
#' To turn off plotting both to screen and disk, set both
#' \code{.plotInititalTime = NA} and \code{.plots = NA} or any other
#' value that will not trigger a TRUE with a \code{grepl} with the \code{types}
#' argument (e.g., \code{""} will omit all saving).
#'
#' @export
#' @param data An arbitrary data object. It should be used inside the \code{Plots}
#'   function, and should contain all the data required for the inner plotting
#' @param fn An arbitrary plotting function.
#' @param filename A name that will be the base for the files that will be saved, i.e,
#'   do not supply the file extension, as this will be determined based on \code{types}.
#'   If a user provides this as an absolute path, it will override the \code{path}
#'   argument.
#' @param types Character vector, zero or more of types. See below.
#' @param path Currently a single path for the saved objects on disk. If \code{filename}
#'   is supplied as an absolute path, \code{path} will be set to \code{dirname(filename)},
#'   overriding this argument value.
#' @param .plotInitialTime A numeric. If \code{NA} then no visual on screen. Anything
#'   else will have visuals plotted to screen device. This is here for backwards
#'   compatibility. A developer should set in the module to the intended initial
#'   plot time and leave it.
#' @param ggsaveArgs An optional list of arguments passed to \code{ggplot2::ggsave}
#' @param deviceArgs An optional list of arguments passed to one of \code{png},
#'       \code{pdf}, \code{tiff}, \code{bmp}, or \code{jgeg}.
#'       This is useful when the plotting function is not creating a \code{ggplot} object.
#'
#' @param usePlot Logical. If \code{TRUE}, the default, then the plot will occur
#'   with \code{quickPlot::Plot}, so it will be arranged with previously existing plots.
#'
#' @param ... Anything needed by \code{fn}
#'
#' @importFrom grDevices dev.off
#' @importFrom qs qsave
#' @importFrom raster writeRaster
#' @importFrom quickPlot clearPlot Plot whereInStack
#'
#' @details
#'
#' \itemize{
#'   \item \code{type}
#'     \itemize{
#'       \item \code{"screen"} -- Will plot to the current device, normally a plot window
#'       \item \code{"object"} -- Will save the plot object, e.g., \code{ggplot} object
#'       \item \code{"raw"} -- Will save the raw data prior to plotting, e.g.,
#'                           the data argument
#'       \item \code{"png"} -- or any other type save-able with \code{ggsave}
#'     }
#' }
#'
#' @examples
#'
#' \dontrun{
#' # Note: if this is used inside a SpaDES module, do not define this
#' #  function inside another function. Put it outside in a normal
#' #  module script. It will cause a memory leak, otherwise.
#' if (!require("ggplot2")) stop("please install ggplot2")
#' fn <- function(d)
#'   ggplot(d, aes(a)) +
#'   geom_histogram()
#' sim <- simInit()
#' sim$something <- data.frame(a = sample(1:10, replace = TRUE))
#'
#' Plots(data = sim$something, fn = fn,
#'       types = c("png"),
#'       path = file.path("figures"),
#'       filename = tempfile(),
#'       .plotInitialTime = 1
#'       )
#'
#' # plot to active device and to png
#' Plots(data = sim$something, fn = fn,
#'       types = c("png", "screen"),
#'       path = file.path("figures"),
#'       filename = tempfile(),
#'       .plotInitialTime = 1
#'       )
#'
#' # Can also be used like quickPlot::Plot, but with control over output type
#' r <- raster::raster(extent(0,10,0,10), vals = sample(1:3, size = 100, replace = TRUE))
#' Plots(r, types = c("screen", "png"), deviceArgs = list(width = 700, height = 500))
#'
#' } # end of dontrun
Plots <- function(data, fn, filename,
                  types = quote(params(sim)[[currentModule(sim)]]$.plots),
                  path = quote(file.path(outputPath(sim), "figures")),
                  .plotInitialTime = quote(params(sim)[[currentModule(sim)]]$.plotInitialTime),
                  ggsaveArgs = list(), usePlot = TRUE,
                  deviceArgs = list(),
                  ...) {

  if (any(is(types, "call") || is(path, "call") || is(.plotInitialTime, "call"))) {
    simIsIn <- parent.frame() # try for simplicity sake... though the whereInStack would get this too
    if (!exists("sim", simIsIn)) {
      simIsIn <- try(whereInStack("sim"), silent = TRUE)
      if (is(simIsIn, "try-error"))
        simIsIn <- NULL
    }
  }

  # Deal with non sim cases
  if (is.null(simIsIn)) {
    if (is.call(types) && any(grepl("sim", types)))
      types <- "screen"
    if (is.call(path) && any(grepl("sim", path)))
      path = "."
    if (is.call(.plotInitialTime) && any(grepl("sim", .plotInitialTime)))
      .plotInitialTime <- 0L
  }

  if (!is.null(simIsIn))
    if (is(types, "call"))
      types <- eval(types, envir = simIsIn)
  if (is(types, "list"))
    types <- unlist(types)

  if (!is.null(simIsIn)) {
    if (is(simIsIn, "try-error")) {
      .plotInitialTime <- 0L
    } else if (is(.plotInitialTime, "call")) {
      .plotInitialTime = try(eval(.plotInitialTime, envir = simIsIn), silent = TRUE)
      if (is(.plotInitialTime, "try-error"))
        .plotInitialTime <- 0L
    }
  } else {
    .plotInitialTime <- 0L
  }

  ggplotClassesCanHandleBar <- paste(ggplotClassesCanHandle, collapse = "|")
  needSave <- any(grepl(paste(ggplotClassesCanHandleBar, "|object"), types))
  needScreen <- !is.na(.plotInitialTime) && any(grepl("screen", types))
  if (missing(fn) && isTRUE(usePlot)) {
    fn <- Plot
  }
  fnIsPlot <- identical(fn, Plot)
  if (fnIsPlot) {
    # make dummies
    gg <- 1
    ggListToScreen <- list()
  } else {
    if ( (needScreen || needSave) ) {
      gg <- fn(data, ...)
      if (!is(gg, ".quickPlot")) {
        ggListToScreen <- setNames(list(gg), "gg")
        if (!is.null(gg$labels$title) && needScreen) {
          ggListToScreen <- setNames(ggListToScreen, gg$labels$title)
          ggListToScreen[[1]]$labels$title <- NULL
        }
      }
    }
  }

  if (needScreen) {
    if (fnIsPlot) {
      gg <- fn(data, ...)
    } else {
      if (is(gg, "gg"))
        if (!requireNamespace("ggplot2")) stop("Please install ggplot2")
      if (usePlot) {
        names(ggListToScreen) <- gsub(names(ggListToScreen), pattern = " ", replacement = "_")
        Plot(ggListToScreen, addTo = gg$labels$title)
      } else {
        print(gg)
      }
    }

  }
  needSaveRaw <- any(grepl("raw", types))
  if (needSave || needSaveRaw) {
    if (missing(filename)) {
      filename <- tempfile(fileext = "")
    }
    isDefaultPath <-  identical(eval(formals(Plots)$path), path)
    if (!is.null(simIsIn)) {
      if (is(path, "call"))
        path <- eval(path, envir = simIsIn)
    }

    if (isAbsolutePath(filename)) {
      path <- dirname(filename)
      filename <- basename(filename)
    }

    if (is(path, "character"))
      checkPath(path, create = TRUE)
  }

  if (needSaveRaw) {
    if (is(data, "Raster")) {
      writeRaster(data, filename = file.path(path, paste0(filename, "_data.tif")))
    } else {
      qs::qsave(data, file.path(path, paste0(filename, "_data.qs")))
    }

  }

  if (needSave) {
    if (is.null(simIsIn)) {
      if (is.call(path))
        path <- "."
      if (is.call(path))
        path <- "."
    }
    if (fnIsPlot) {
      baseSaveFormats <- intersect(baseClassesCanHandle, types)
      for (bsf in baseSaveFormats) {
        type <- get(bsf)
        theFilename <- file.path(path, paste0(filename, ".", bsf))
        do.call(type, modifyList(list(theFilename), deviceArgs))
        # curDev <- dev.cur()
        clearPlot()
        plotted <- try(fn(data, ...)) # if this fails, catch so it can be dev.off'd
        dev.off()
        if (!is(plotted, "try-error"))
          message("Saved figure to: ", theFilename)
      }
    } else {
      ggSaveFormats <- intersect(ggplotClassesCanHandle, types)
      for (ggsf in ggSaveFormats) {
        theFilename <- file.path(path, paste0(filename, ".", ggsf))
        if (!requireNamespace("ggplot2")) stop("To save gg objects, need ggplot2 installed")
        args <- list(plot = gg,
                     filename = theFilename)
        if (length(ggsaveArgs)) {
          args <- modifyList(args, ggsaveArgs)
        }
        do.call(ggplot2::ggsave, args = args)
        message("Saved figure to: ", theFilename)
      }
    }

    if (any(grepl("object", types)))
      qs::qsave(gg, file = file.path(path, paste0(filename, "_gg.qs")))
  }
}

#' Test whether there should be any plotting from .plot parameter
#'
#' This will do all the various tests needed to determine whether
#' plotting of one sort or another will occur. Testing any of the
#' types as listed in \code{\link{Plots}} argument \code{types}. Only the
#' first 3 letters of the type are required.
#'
#' @param .plots Usually will be the \code{P(sim)$.plots} is used within
#'   a module.
#'
#' @export
anyPlotting <- function(.plots) {
  needSaveRaw <- any(grepl("raw", .plots))
  ggplotClassesCanHandleBar <- paste(ggplotClassesCanHandle, collapse = "|")
  needSave <- any(grepl(paste(ggplotClassesCanHandleBar, "|obj"), .plots))
  needScreen <- any(grepl("scr", .plots))

  needSaveRaw || needSave || needScreen
}

ggplotClassesCanHandle <- c("eps", "ps", "tex", "pdf", "jpeg", "tiff", "png", "bmp", "svg", "wmf")
baseClassesCanHandle <- c("pdf", "jpeg", "png", "tiff", "bmp")
