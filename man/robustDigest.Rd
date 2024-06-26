% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/cache.R
\name{.robustDigest,simList-method}
\alias{.robustDigest,simList-method}
\alias{Cache}
\title{\code{.robustDigest} for \code{simList} objects}
\usage{
\S4method{.robustDigest}{simList}(object, .objects, length, algo, quick, classOptions)
}
\arguments{
\item{object}{an object to digest.}

\item{.objects}{Character vector of objects to be digested. This is only applicable
if there is a list, environment (or similar) with named objects
within it. Only this/these objects will be considered for caching,
i.e., only use a subset of
the list, environment or similar objects. In the case of nested list-type
objects, this will only be applied outermost first.}

\item{length}{Numeric. If the element passed to Cache is a \code{Path} class
object (from e.g., \code{asPath(filename)}) or it is a \code{Raster} with
file-backing, then this will be
passed to \code{digest::digest}, essentially limiting the number of bytes
to digest (for speed). This will only be used if \code{quick = FALSE}.
Default is \code{getOption("reproducible.length")}, which is set to \code{Inf}.}

\item{algo}{The algorithms to be used; currently available choices are
    \code{md5}, which is also the default, \code{sha1}, \code{crc32},
    \code{sha256}, \code{sha512}, \code{xxhash32}, \code{xxhash64},
    \code{murmur32}, \code{spookyhash}, \code{blake3}, \code{crc32c},
    \code{xxh3_64}, and \code{xxh3_128}.}

\item{quick}{Logical or character. If \code{TRUE},
no disk-based information will be assessed, i.e., only
memory content. See Details section about \code{quick} in \code{\link[reproducible:Cache]{Cache()}}.}

\item{classOptions}{Optional list. This will pass into \code{.robustDigest} for
specific classes. Should be options that the \code{.robustDigest} knows what
to do with.}
}
\description{
This is intended to be used within the \code{Cache} function, but can be used to evaluate what
a \code{simList} would look like once it is converted to a repeatably digestible object.
}
\details{
See \code{\link[reproducible:robustDigest]{reproducible::.robustDigest()}}.
This method strips out stuff from a \code{simList} class object that would make it otherwise not
reproducibly digestible between sessions, operating systems, or machines.
This will likely still not allow identical digest results across R versions.
}
\seealso{
\code{\link[reproducible:robustDigest]{reproducible::.robustDigest()}}
}
\author{
Eliot McIntire
}
