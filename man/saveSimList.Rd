% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/saveLoadSimList.R
\name{saveSimList}
\alias{saveSimList}
\alias{saveSim}
\alias{zipSimList}
\title{Save a whole \code{simList} object to disk}
\usage{
saveSimList(sim, filename, fileBackend = 0, filebackedDir = NULL, envir, ...)

zipSimList(sim, zipfile, ..., outputs = TRUE, inputs = TRUE, cache = FALSE)
}
\arguments{
\item{sim}{Either a \code{simList} or a character string of the name
of a \code{simList} that can be found in \code{envir}. Using
a character string will assign that object name to the saved
\code{simList}, so when it is recovered it will be given that
name.}

\item{filename}{Character string with the path for saving \code{simList} to or
reading the \code{simList} from}

\item{fileBackend}{Numeric. \code{0} means don't do anything with
file backed rasters. Leave their file intact as is, in its place.
\code{1} means save a copy of the file backed rasters in \code{fileBackedDir}.
\code{2} means move all data in file-backed rasters to memory. This
means that the objects will be part of the main \code{qs} file
of the \code{simList}. Default is \code{0}.}

\item{filebackedDir}{Only used if \code{fileBackend} is 1.
\code{NULL}, the default, or Character string. If \code{NULL}, then then the
files will be copied to the directory:
\code{file.path(dirname(filename), "rasters")}. A character string
will be interpreted as a path to copy all rasters to.}

\item{envir}{If \code{sim} is a character string, then this must be provided.
It is the environment where the object named \code{sim} can be found.}

\item{...}{passed to \code{\link{saveSimList}}, including non-optional ones
such as \code{filename}. Also see \code{fileBackend} and \code{filebackedDir}
arguments in that function.}

\item{zipfile}{A character string indicating the filename for the zip file. Passed to \code{zip}.}

\item{outputs}{Logical. If \code{TRUE}, all files identified in
\code{outputs(sim)} will be included in the zip.}

\item{inputs}{Logical. If \code{TRUE}, all files identified in
\code{inputs(sim)} will be included in the zip.}

\item{cache}{Logical. Not yet implemented. If \code{TRUE}, all files in \code{cachePath(sim)} will be included in the
zip archive. Defaults to \code{FALSE} as this could be large, and may include many
out of date elements. See Details.}
}
\value{
\code{\link[=saveSimList]{saveSimList()}}: A saved \code{.qs} file in \code{filename} location.

\code{\link[=zipSimList]{zipSimList()}}: A saved \code{.zip} file in \code{zipfile} location.
}
\description{
Saving a \code{simList} may not work using the standard approaches (e.g.,
\code{save}, \code{saveRDS}, and \code{qs::qsave}). There are 2 primary reasons why this doesn't
work as expected: the \code{activeBindings} that are in place within modules (these
allow the \code{mod} and \code{Par} to exist), and file-backed rasters. Because of these,
a user should use \code{saveSimList} and \code{loadSimList} (and the \code{zipSimList}/\code{unzipSimList}
alternatives).
The most robust way if there are file-backed Raster* objects seems to be to
set \code{fileBackend = 2}, though this may not be desirable if there are many
large \verb{Raster*} objects. When using \code{fileBackend = 0} or \code{fileBackend = 1}, and
when errors are noticed, please file a bug report on GitHub.

\code{zipSimList} will save the \code{simList} and file-backed \verb{Raster*} objects, plus,
optionally, files identified in \code{outputs(sim)} and \code{inputs(sim)}.
This uses \code{Copy} under the hood, to not affect the original
\code{simList}. \strong{VERY experimental}.
}
\details{
There is a family of 4 functions that are mutually useful for saving and
loading \code{simList} objects and their associated files (e.g., file-backed
\verb{Raster*}, \code{inputs}, \code{outputs}, \code{cache}) \code{\link[=saveSimList]{saveSimList()}}, \code{\link[=loadSimList]{loadSimList()}},
\code{\link[=zipSimList]{zipSimList()}}, \code{\link[=unzipSimList]{unzipSimList()}}

\subsection{Save - Move - Load}{

There are 3 different workflows for "save - move files - load" that work in our tests:
\enumerate{
\item \code{filebackend = 0}: No renaming of file-backed rasters, on recovery attempts to rebuild

This approach is attempting to emulate a "relative filenames" approach,
i.e., attempt to treat the file-backed raster file names as if they were
relative (which they are not -- raster package forces absolute file
paths). To do this, all the renaming occurs within \code{loadSimList} or
\code{unzipSimList}. These function will use the \code{paths} argument to rewrite
the paths of the files that are identified with \code{Filenames(sim)} so that
they are in the equivalent (relative) position as they were. This will
only work if all files were in one of the \code{paths} of the original
\code{simList}, so that they can be matched up with the new \code{paths} passed in
\code{loadSimList}. This is not guaranteed to work correctly, though it works
in a wide array of testing.\preformatted{zipSimList(sim, zipfile = tmpZip, filename = "sim.qs")
pths <- getPaths(mySim)
out <- unzipSimList(tmpZip, paths = pths)
}
\item \code{filebackend = 1}: On the fly renaming of file-backed rasters;
\enumerate{
\item Save the sim object with a filename, e.g.,  \code{file},
\item make a copy of all file-backed rasters to \code{fileBackedDir},
\item update all the pointers to those files so that they are correct in the raster metadata
}\preformatted{saveSimList(sim, file = "sim.qs", fileBackend = 1, fileBackedDir = "here")
simNew <- loadSimList(file = "sim.qs")
}
\item \code{filebackend = 2}: On the fly bringing to memory of all rasters

All rasters are brought to memory, and then saved into \code{sim.qs}\preformatted{saveSimList(sim, file = "sim.qs", fileBackend = 2)
simNew <- loadSimList(file = "sim.qs")
}
}

If \code{cache} is used, it is likely that it should be trimmed before
zipping, to include only cache elements that are relevant.
}
}
\seealso{
\code{\link[=loadSimList]{loadSimList()}}, \code{\link[=unzipSimList]{unzipSimList()}}
}
