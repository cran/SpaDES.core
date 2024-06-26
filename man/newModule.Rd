% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/module-template.R
\name{newModule}
\alias{newModule}
\alias{newModule,character,character-method}
\alias{newModule,character,missing-method}
\title{Create new module from template}
\usage{
newModule(name, path, ..., events, envir = parent.frame())

\S4method{newModule}{character,character}(name, path, ..., events, envir = parent.frame())

\S4method{newModule}{character,missing}(name, path, ..., events, envir = parent.frame())
}
\arguments{
\item{name}{Character string specifying the name of the new module.}

\item{path}{Character string. Subdirectory in which to place the new module code file.
The default is the current working directory.}

\item{...}{Additional arguments. Currently, these can be either named
function definitions (which will be added to the \code{simList}) or one or
more of the following:\cr\cr
\describe{
\item{\code{children}}{Required when \code{type = "parent"}. A character vector
specifying the names of child modules.}
\item{\code{open}}{Logical. Should the new module file be opened after creation?
Default \code{TRUE}.}
\item{\code{type}}{Character string specifying one of \code{"child"} (default),
or \code{"parent"}.}
\item{\code{unitTests}}{Logical. Should the new module include unit test files?
Default \code{TRUE}. Unit testing relies on the \pkg{testthat} package.}
\item{\code{useGitHub}}{Logical. Is module development happening on GitHub?
Default \code{TRUE}.}
}}

\item{events}{A list of named expressions, each of which is surrounded by \code{{ }}.
A user can specify events here, instead of accepting the default \code{doEvent} function
that comes with the module template. See example.}

\item{envir}{An environment where objects being passed to \code{newModule} can be found.
Default \code{parent.frame()}, which should be fine for most cases.}
}
\value{
NULL (invisibly). The new module file is created at
\file{path/name.R}, as well as ancillary files for documentation, citation,
\file{LICENSE}, \file{README}, and \file{tests} directory.
}
\description{
Generate a skeleton for a new SpaDES module, a template for a
documentation file, a citation file, a license file, a \file{README.md} file,
and a folder that contains unit tests information.
The \code{newModuleDocumentation} will not generate the module file, but will
create the other files.
}
\details{
All files will be created within a subdirectory named \code{name} within the \code{path}:

\if{html}{\out{<div class="sourceCode">}}\preformatted{  <path>/
    |_ <name>/
    |_ R/               # contains additional module R scripts
    |_ data/            # directory for all included data
      |_ CHECKSUMS.txt  # contains checksums for data files
    |_ tests/           # contains unit tests for module code
    |_ citation.bib     # bibtex citation for the module
    |_ LICENSE          # describes module's legal usage
    |_ README.md        # provide overview of key aspects
    |_ <name>.R         # module code file (incl. metadata)
    |_ <name>.Rmd       # documentation, usage info, etc.
}\if{html}{\out{</div>}}
}
\note{
On Windows there is currently a bug in RStudio that prevents the editor
from opening when \code{file.edit} is called.
Similarly, in RStudio on macOS, there is an issue opening files where they
are opened in an overlaid window rather than a new tab.
\code{file.edit} does work if the user types it at the command prompt.
A message with the correct lines to copy and paste is provided.
}
\examples{
\donttest{
  tmpdir <- tempdir2("exampleNewModule")
  ## create a "myModule" module in the "modules" subdirectory.
  newModule("myModule", tmpdir)

  ## create a new parent module in the "modules" subdirectory.
  newModule("myParentModule", tmpdir, type = "parent", children = c("child1", "child2"))
  unlink(tmpdir, recursive = TRUE)
}

}
\seealso{
Other module creation helpers: 
\code{\link{newModuleCode}()},
\code{\link{newModuleDocumentation}()},
\code{\link{newModuleTests}()}
}
\author{
Alex Chubaty and Eliot McIntire
}
\concept{module creation helpers}
