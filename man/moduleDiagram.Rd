% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plotting-diagrams.R
\name{moduleDiagram}
\alias{moduleDiagram}
\alias{moduleDiagram,simList,character,logical-method}
\alias{moduleDiagram,simList,ANY,ANY-method}
\title{Simulation module dependency diagram}
\usage{
moduleDiagram(sim, type, showParents = TRUE, ...)

\S4method{moduleDiagram}{simList,character,logical}(sim, type = "plot", showParents = TRUE, ...)

\S4method{moduleDiagram}{simList,ANY,ANY}(sim, type, showParents = TRUE, ...)
}
\arguments{
\item{sim}{A \code{simList} object (typically corresponding to a
completed simulation).}

\item{type}{Character string, either \code{"rgl"} for \code{igraph::rglplot}
or \code{"tk"} for \code{igraph::tkplot}, \code{"Plot"} to use \code{quickPlot::Plot()}
or \code{"plot"} to use \code{base::plot()}, the default.}

\item{showParents}{Logical. If TRUE, then any children that are grouped into parent
modules will be grouped together by coloured blobs. Internally,
this is calling \code{\link[=moduleGraph]{moduleGraph()}}. Default \code{FALSE}.}

\item{...}{Additional arguments passed to plotting function specified by \code{type}.}
}
\value{
invoked for its side effect of plotting the module dependency diagram.
}
\description{
Create a network diagram illustrating the simplified module dependencies of a
simulation. Offers a less detailed view of specific objects than does
plotting the \code{depsEdgeList} directly with \code{\link[=objectDiagram]{objectDiagram()}}.
}
\examples{
\donttest{
if (requireNamespace("SpaDES.tools", quietly = TRUE) &&
    requireNamespace("NLMR", quietly = TRUE)) {
library(igraph)
times <- list(start = 0, end = 6, "month")
parameters <- list(
  .globals = list(stackName = "landscape"),
  caribouMovement = list(
    .saveObjects = "caribou",
    .saveInitialTime = 1, .saveInterval = 1
  ),
  randomLandscapes = list(.plotInitialTime = NA, nx = 20, ny = 20))

modules <- list("randomLandscapes", "caribouMovement")
paths <- list(
  modulePath = getSampleModules(tempdir())
)

# Set some options so example runs faster
opts <- options(spades.moduleCodeChecks = FALSE, spades.loadReqdPkgs = FALSE)
sim <- simInit(times = times, params = parameters, modules = modules,
               paths = paths)
options(opts)
moduleDiagram(sim)
# Can also use default base::plot
modDia <- depsGraph(sim, plot = TRUE)
# See ?plot.igraph
plot(modDia, layout = layout_as_star)

# Or for more control - here, change the label "_INPUT_" to "DATA"
edgeList <- depsEdgeList(sim)
edgeList <- edgeList[, list(from, to)]
edgeList[from == "_INPUT_", from := "Data"]
edgeList[to == "_INPUT_", to := "Data"]
edgeList <- unique(edgeList)
ig <- graph_from_data_frame(edgeList[, list(from, to)])
plot(ig)
}
}

}
\seealso{
\code{\link[=igraph]{igraph()}}, \code{\link[=moduleGraph]{moduleGraph()}} for a version that accounts for
parent and children module structure.
}
\author{
Alex Chubaty
}
