% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Plots.R
\name{Plots}
\alias{Plots}
\title{\code{Plot} wrapper intended for use in a SpaDES module}
\usage{
Plots(
  data,
  fn,
  filename,
  types = quote(params(sim)[[currentModule(sim)]]$.plots),
  path = quote(file.path(outputPath(sim), "figures")),
  .plotInitialTime = quote(params(sim)[[currentModule(sim)]]$.plotInitialTime),
  ggsaveArgs = list(),
  usePlot = TRUE,
  deviceArgs = list(),
  ...
)
}
\arguments{
\item{data}{An arbitrary data object. It should be used inside the \code{Plots}
function, and should contain all the data required for the inner plotting}

\item{fn}{An arbitrary plotting function.}

\item{filename}{A name that will be the base for the files that will be saved, i.e,
do not supply the file extension, as this will be determined based on \code{types}.
If a user provides this as an absolute path, it will override the \code{path}
argument.}

\item{types}{Character vector, zero or more of types. See below.}

\item{path}{Currently a single path for the saved objects on disk. If \code{filename}
is supplied as an absolute path, \code{path} will be set to \code{dirname(filename)},
overriding this argument value.}

\item{.plotInitialTime}{A numeric. If \code{NA} then no visual on screen. Anything
else will have visuals plotted to screen device. This is here for backwards
compatibility. A developer should set in the module to the intended initial
plot time and leave it.}

\item{ggsaveArgs}{An optional list of arguments passed to \code{ggplot2::ggsave}}

\item{usePlot}{Logical. If \code{TRUE}, the default, then the plot will occur
with \code{quickPlot::Plot}, so it will be arranged with previously existing plots.}

\item{deviceArgs}{An optional list of arguments passed to one of \code{png},
\code{pdf}, \code{tiff}, \code{bmp}, or \code{jgeg}.
This is useful when the plotting function is not creating a \code{ggplot} object.}

\item{...}{Anything needed by \code{fn}}
}
\description{
This is a single function call that allows a module to change which format in which
the plots will occur.
Specifically, the two primary formats would be to \code{"screen"} or to disk as an image file,
such as \code{"png"}.
\emph{THIS CURRENTLY ONLY WORKS CORRECTLY WITH \code{ggplot2} objects that can be saved.}
It uses \code{Plot} internally, so individual plots may be rearranged.
This function requires at least 2 things: a plotting function and data for that plot function.
See below and examples.
}
\details{
\itemize{
\item \code{type}
\itemize{
\item \code{"screen"} -- Will plot to the current device, normally a plot window
\item \code{"object"} -- Will save the plot object, e.g., \code{ggplot} object
\item \code{"raw"} -- Will save the raw data prior to plotting, e.g.,
the data argument
\item \code{"png"} -- or any other type save-able with \code{ggsave}
}
}
}
\note{
THIS IS STILL EXPERIMENTAL and could change in the next release.

\code{Plots} now has experimental support for "just a \code{Plot} call",
but with \code{types} specified.
See example.
The devices to save on disk will have some different behaviours to the screen representation,
since "wiping" an individual plot on a device doesn't exist for a file device.

This offers up to 4 different actions for a given plot:
\itemize{
\item To screen device
\item To disk as raw data
\item To disk as a saved plot object
\item To disk as a \file{.png} or other image file, e.g., \file{.pdf}
}
To turn off plotting both to screen and disk, set both
\code{.plotInititalTime = NA} and \code{.plots = NA} or any other
value that will not trigger a TRUE with a \code{grepl} with the \code{types}
argument (e.g., \code{""} will omit all saving).
}
\examples{

\dontrun{
# Note: if this is used inside a SpaDES module, do not define this
#  function inside another function. Put it outside in a normal
#  module script. It will cause a memory leak, otherwise.
if (!require("ggplot2")) stop("please install ggplot2")
fn <- function(d)
  ggplot(d, aes(a)) +
  geom_histogram()
sim <- simInit()
sim$something <- data.frame(a = sample(1:10, replace = TRUE))

Plots(data = sim$something, fn = fn,
      types = c("png"),
      path = file.path("figures"),
      filename = tempfile(),
      .plotInitialTime = 1
      )

# plot to active device and to png
Plots(data = sim$something, fn = fn,
      types = c("png", "screen"),
      path = file.path("figures"),
      filename = tempfile(),
      .plotInitialTime = 1
      )

# Can also be used like quickPlot::Plot, but with control over output type
r <- raster::raster(extent(0,10,0,10), vals = sample(1:3, size = 100, replace = TRUE))
Plots(r, types = c("screen", "png"), deviceArgs = list(width = 700, height = 500))

} # end of dontrun
}
