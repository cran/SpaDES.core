% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/cache.R
\name{.cacheMessage,simList-method}
\alias{.cacheMessage,simList-method}
\title{\code{.cacheMessage} for \code{simList} objects}
\usage{
\S4method{.cacheMessage}{simList}(
  object,
  functionName,
  fromMemoise = getOption("reproducible.useMemoise", TRUE),
  verbose = getOption("reproducible.verbose")
)
}
\arguments{
\item{object}{Any R object returned from a function}

\item{functionName}{A character string indicating the function name}

\item{fromMemoise}{Logical. If \code{TRUE}, the message will be about
recovery from memoised copy}

\item{verbose}{Numeric, -1 silent (where possible), 0 being very quiet,
1 showing more messaging, 2 being more messaging, etc.
Default is 1. Above 3 will output much more information about the internals of
Caching, which may help diagnose Caching challenges. Can set globally with an
option, e.g., \verb{options('reproducible.verbose' = 0) to reduce to minimal}}
}
\description{
See \code{\link[reproducible:exportedMethods]{reproducible::.cacheMessage()}}.
}
\seealso{
\link[reproducible:exportedMethods]{reproducible::.cacheMessage}
}
