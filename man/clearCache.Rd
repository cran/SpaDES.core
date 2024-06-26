% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/cache.R
\name{clearCache,simList-method}
\alias{clearCache,simList-method}
\alias{showCache,simList-method}
\alias{keepCache,simList-method}
\title{\code{clearCache} for \code{simList} objects}
\usage{
\S4method{clearCache}{simList}(
  x,
  userTags = character(),
  after = NULL,
  before = NULL,
  fun = NULL,
  cacheId = NULL,
  ask = getOption("reproducible.ask"),
  useCloud = FALSE,
  cloudFolderID = getOption("reproducible.cloudFolderID", NULL),
  drv = getDrv(getOption("reproducible.drv", NULL)),
  conn = getOption("reproducible.conn", NULL),
  verbose = getOption("reproducible.verbose"),
  ...
)

\S4method{showCache}{simList}(
  x,
  userTags = character(),
  after = NULL,
  before = NULL,
  fun = NULL,
  cacheId = NULL,
  drv = getDrv(getOption("reproducible.drv", NULL)),
  conn = getOption("reproducible.conn", NULL),
  verbose = getOption("reproducible.verbose"),
  ...
)

\S4method{keepCache}{simList}(
  x,
  userTags = character(),
  after = NULL,
  before = NULL,
  ask = getOption("reproducible.ask"),
  drv = getDrv(getOption("reproducible.drv", NULL)),
  conn = getOption("reproducible.conn", NULL),
  verbose = getOption("reproducible.verbose"),
  ...
)
}
\arguments{
\item{x}{A simList or a directory containing a valid Cache repository. Note:
For compatibility with \code{Cache} argument, \code{cachePath} can also be
used instead of \code{x}, though \code{x} will take precedence.}

\item{userTags}{Character vector. If used, this will be used in place of the
\code{after} and \code{before}.
Specifying one or more \code{userTag} here will clear all
objects that match those tags.
Matching is via regular expression, meaning partial matches
will work unless strict beginning (\code{^}) and end (\code{$}) of string
characters are used.
Matching will be against any of the 3 columns returned by \code{showCache()},
i.e., \code{artifact}, \code{tagValue} or \code{tagName}.
Also, if \code{length(userTags) > 1}, then matching is by \code{and}.
For \code{or} matching, use \code{|} in a single character string.
See examples.}

\item{after}{A time (POSIX, character understandable by data.table).
Objects cached after this time will be shown or deleted.}

\item{before}{A time (POSIX, character understandable by data.table).
Objects cached before this time will be shown or deleted.}

\item{fun}{An optional character vector describing the function name to extract.
Only functions with this/these functions will be returned.}

\item{cacheId}{An optional character vector describing the \code{cacheId}s to extract.
Only entries with this/these \code{cacheId}s will be returned. If \code{useDBI(FALSE)},
this will also be dramatically faster than using \code{userTags}, for a large
cache.}

\item{ask}{Logical. If \code{FALSE}, then it will not ask to confirm deletions using
\code{clearCache} or \code{keepCache}. Default is \code{TRUE}}

\item{useCloud}{Logical. If \code{TRUE}, then every object that is deleted locally will
also be deleted in the \code{cloudFolderID}, if it is non-\code{NULL}}

\item{cloudFolderID}{A googledrive dribble of a folder, e.g., using \code{drive_mkdir()}.
If left as \code{NULL}, the function will create a cloud folder with name from last
two folder levels of the \code{cachePath} path, :
\code{paste0(basename(dirname(cachePath)), "_", basename(cachePath))}.
This \code{cloudFolderID} will be added to \code{options("reproducible.cloudFolderID")},
but this will not persist across sessions. If this is a character string, it will
treat this as a folder name to create or use on GoogleDrive.}

\item{drv}{an object that inherits from \code{DBIDriver}, or an existing
\code{DBIConnection} object (in order to clone an existing connection).}

\item{conn}{A \code{DBIConnection} object, as returned by \code{dbConnect()}.}

\item{verbose}{Numeric, -1 silent (where possible), 0 being very quiet,
1 showing more messaging, 2 being more messaging, etc.
Default is 1. Above 3 will output much more information about the internals of
Caching, which may help diagnose Caching challenges. Can set globally with an
option, e.g., \verb{options('reproducible.verbose' = 0) to reduce to minimal}}

\item{...}{Other arguments. Can be in the form of \code{tagKey = tagValue}, such as,
\code{class = "numeric"} to find all entries that are numerics in the cache.
Note: the special cases of \code{cacheId} and \code{fun} have their own
named arguments in these functions.
Also can be \code{regexp = xx}, where \code{xx} is \code{TRUE} if the user
is passing a regular expression.
Otherwise, \code{userTags} will need to be exact matches. Default is
missing, which is the same as \code{TRUE}. If there are errors due
to regular expression problem, try \code{FALSE}. For \code{cc}, it is
passed to \code{clearCache}, e.g., \code{ask}, \code{userTags}. For \code{showCache},
it can also be \code{sorted = FALSE} to return the object unsorted.}
}
\value{
A \code{data.table} object showing the subset of items in the cache, located at \code{cachePath}
of the \code{sim} object, if \code{sim} is provided, or located in \code{cachePath}.
For \code{clearCache} (invoked for its side effect of clearing objects matching \code{userTags}, or those
between \code{after} or \code{before}), the returned \code{data.table} shows the removed items (invisibly).
}
\description{
This will take the \code{cachePath(object)} and pass
}
