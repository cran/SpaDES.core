utils::globalVariables(c(
  "newQuantity", "quantityAdj", "quantityAdj2"
))

#' A slightly modified version of `getOption()`
#'
#' This can take `x` as a character string or as a function that returns a character string.
#'
#' @inheritParams base::getOption
#' @rdname getOption
#' @keywords internal
.getOption <- function(x, default = NULL) {
  optionDefault <- options(x)[[1]]
  if (is.null(optionDefault)) optionDefault <- default
  if (is.function(optionDefault)) {
    optionDefault()
  } else {
    optionDefault
  }
}

#' Update elements of a named list with elements of a second named list
#'
#' Defunct. Use [utils::modifyList()] (which can not handle NULL) or
#' [Require::modifyList2()] for case with >2 lists and can handle NULL lists.
#'
#' @param x,y   a named list
#'
#' @return A named list, with elements sorted by name.
#'          The values of matching elements in list `y`
#'          replace the values in list `x`.
#'
#' @author Alex Chubaty
#' @export
#' @importFrom Require modifyList2
#' @rdname updateList
updateList <- function(x, y) {
  .Defunct("Require::modifyList2", "Require")
}

# append_attr ---------------------------------------------------------------------------------

#' Append attributes
#'
#' Ordinary base lists and vectors do not retain their attributes
#' when subsetted or appended.
#' This function appends items to a list while preserving the
#' attributes of items in the list (but not of the list itself).
#'
#' Similar to `updateList` but does not require named lists.
#'
#' @param x,y  A `list` of items with optional attributes.
#'
#' @return An updated `list` with attributes.
#'
#' @author Alex Chubaty and Eliot McIntire
#' @export
#' @rdname append_attr
#'
#' @examples
#' tmp1 <- list("apple", "banana")
#' tmp1 <- lapply(tmp1, `attributes<-`, list(type = "fruit"))
#' tmp2 <- list("carrot")
#' tmp2 <- lapply(tmp2, `attributes<-`, list(type = "vegetable"))
#' append_attr(tmp1, tmp2)
#' rm(tmp1, tmp2)
setGeneric("append_attr", function(x, y) {
  standardGeneric("append_attr")
})

#' @export
#' @rdname append_attr
setMethod("append_attr",
          signature = c(x = "list", y = "list"),
          definition = function(x, y) {
            attrs <- c(lapply(x, attributes), lapply(y, attributes))
            out <- append(x, y)
            if (length(out)) {
              for (i in length(out)) {
                attributes(out[i]) <- attrs[[i]]
              }
            }
            dups <- duplicated(out) # unique strips names ... out[!dups] does not
            return(out[!dups])
})

# random strings ------------------------------------------------------------------------------

#' @rdname rndstr
.rndstr <- function(n = 1, len = 8) {
  unlist(lapply(character(n), function(x) {
    x <- paste0(sample(c(0:9, letters, LETTERS), size = len,
                       replace = TRUE), collapse = "")
  }))
}

#' Generate random strings
#'
#' Generate a vector of random alphanumeric strings each of an arbitrary length.
#'
#' @param n   Number of strings to generate (default 1).
#'            Will attempt to coerce to integer value.
#'
#' @param len Length of strings to generate (default 8).
#'            Will attempt to coerce to integer value.
#'
#' @param characterFirst Logical, if `TRUE`, then a letter will be the
#'        first character of the string (useful if being used for object names).
#'
#' @return Character vector of random strings.
#'
#' @export
#' @rdname rndstr
#'
#' @author Alex Chubaty and Eliot McIntire
#' @examples
#' set.seed(11)
#' rndstr()
#' rndstr(len = 10)
#' rndstr(characterFirst = FALSE)
#' rndstr(n = 5, len = 10)
#' rndstr(n = 5)
#' rndstr(n = 5, characterFirst = TRUE)
#' rndstr(len = 10, characterFirst = TRUE)
#' rndstr(n = 5, len = 10, characterFirst = TRUE)
#'
setGeneric("rndstr", function(n, len, characterFirst) {
  standardGeneric("rndstr")
})

#' @rdname rndstr
setMethod(
  "rndstr",
  signature(n = "numeric", len = "numeric", characterFirst = "logical"),
  definition = function(n, len, characterFirst) {
    if (!((n > 0) & (len > 0))) {
      stop("rndstr requires n > 0 and len > 0")
    }

    unlist(lapply(character(as.integer(n)), function(x) {
      i <- as.integer(characterFirst)
      x <- paste0(c(sample(c(letters, LETTERS), size = i),
                    sample(c((0:9), letters, LETTERS),
                           size = as.integer(len) - i, replace = TRUE)),
                  collapse = "")
      }))
})

#' @rdname rndstr
setMethod("rndstr",
          signature(n = "numeric", len = "numeric", characterFirst = "missing"),
          definition = function(n, len) {
            rndstr(n = n, len = len, characterFirst = TRUE)
})

#' @rdname rndstr
setMethod("rndstr",
          signature(n = "numeric", len = "missing", characterFirst = "logical"),
          definition = function(n, characterFirst) {
            rndstr(n = n, len = 8, characterFirst = characterFirst)
})

#' @rdname rndstr
setMethod("rndstr",
          signature(n = "missing", len = "numeric", characterFirst = "logical"),
          definition = function(len, characterFirst) {
            rndstr(n = 1, len = len, characterFirst = characterFirst)
})

#' @rdname rndstr
setMethod("rndstr",
          signature(n = "numeric", len = "missing", characterFirst = "missing"),
          definition = function(n) {
            rndstr(n = n, len = 8, characterFirst = TRUE)
})

#' @rdname rndstr
setMethod("rndstr",
          signature(n = "missing", len = "numeric", characterFirst = "missing"),
          definition = function(len) {
            rndstr(n = 1, len = len, characterFirst = TRUE)
})

#' @rdname rndstr
setMethod("rndstr",
          signature(n = "missing", len = "missing", characterFirst = "logical"),
          definition = function(characterFirst) {
            rndstr(n = 1, len = 8, characterFirst = characterFirst)
})

#' @rdname rndstr
setMethod("rndstr",
          signature(n = "missing", len = "missing", characterFirst = "missing"),
          definition = function(n, len, characterFirst) {
            rndstr(n = 1, len = 8, characterFirst = TRUE)
})


# classFilter ---------------------------------------------------------------------------------

#' Filter objects by class
#'
#' Based on <https://stackoverflow.com/a/5158978/1380598>.
#'
#' @param x Character vector of object names to filter, possibly from `ls`.
#'
#' @param include   Class(es) to include, as a character vector.
#'
#' @param exclude   Optional class(es) to exclude, as a character vector.
#'
#' @param envir     The environment ins which to search for objects.
#'                  Default is the calling environment.
#'
#' @return Vector of object names matching the class filter.
#'
#' @note [inherits()] is used internally to check the object class,
#' which can, in some cases, return results inconsistent with `is`.
#' See <https://stackoverflow.com/a/27923346/1380598>.
#' These (known) cases are checked manually and corrected.
#'
#' @export
#' @rdname classFilter
#'
#' @author Alex Chubaty
#'
#' @examples
#'
#' ## from local (e.g., function) environment
#' local({
#'   e <- environment()
#'   a <- list(1:10)     # class `list`
#'   b <- letters        # class `character`
#'   d <- stats::runif(10)      # class `numeric`
#'   f <- sample(1L:10L) # class `numeric`, `integer`
#'   g <- lm( jitter(d) ~ d ) # class `lm`
#'   h <- glm( jitter(d) ~ d ) # class `lm`, `glm`
#'   classFilter(ls(), include=c("character", "list"), envir = e)
#'   classFilter(ls(), include = "numeric", envir = e)
#'   classFilter(ls(), include = "numeric", exclude = "integer", envir = e)
#'   classFilter(ls(), include = "lm", envir = e)
#'   classFilter(ls(), include = "lm", exclude = "glm", envir = e)
#'   rm(a, b, d, e, f, g, h)
#' })
#'
#' ## from another environment (can be omitted if .GlobalEnv)
#' e = new.env(parent = emptyenv())
#' e$a <- list(1:10)     # class `list`
#' e$b <- letters        # class `character`
#' e$d <- stats::runif(10)      # class `numeric`
#' e$f <- sample(1L:10L) # class `numeric`, `integer`
#' e$g <- lm( jitter(e$d) ~ e$d ) # class `lm`
#' e$h <- glm( jitter(e$d) ~ e$d ) # class `lm`, `glm`
#' classFilter(ls(e), include=c("character", "list"), envir = e)
#' classFilter(ls(e), include = "numeric", envir = e)
#' classFilter(ls(e), include = "numeric", exclude = "integer", envir = e)
#' classFilter(ls(e), include = "lm", envir = e)
#' classFilter(ls(e), include = "lm", exclude = "glm", envir = e)
#' rm(a, b, d, f, g, h, envir = e)
#' rm(e)
#'
setGeneric("classFilter", function(x, include, exclude, envir) {
  standardGeneric("classFilter")
})

#' @rdname classFilter
setMethod(
  "classFilter",
  signature(x = "character", include = "character", exclude = "character",
            envir = "environment"),
  definition = function(x, include, exclude, envir) {
    f <- function(w) {
      # -------------------- #
      # using `inherits` doesn't work as expected in some cases,
      #  so we tweak the 'include' to work with those cases:
      if (("numeric" %in% include) &
          (inherits(get(w, envir = envir), "integer")) ) {
        include <- c(include, "integer")
      }
      # --- end tweaking --- #

      if (is.na(exclude)) {
        inherits(get(w, envir = envir), include)
      } else {
        inherits(get(w, envir = envir), include) &
          !inherits(get(w, envir = envir), exclude)
      }
    }
    return(Filter(f, x))
})

#' @rdname classFilter
setMethod(
  "classFilter",
  signature(x = "character", include = "character", exclude = "character",
            envir = "missing"),
  definition = function(x, include, exclude) {
    return(classFilter(x, include, exclude, envir = sys.frame(-1)))
})

#' @rdname classFilter
setMethod(
  "classFilter",
  signature(x = "character", include = "character", exclude = "missing",
            envir = "environment"),
  definition = function(x, include, envir) {
    return(classFilter(x, include, exclude = NA_character_, envir = envir))
})

#' @rdname classFilter
setMethod(
  "classFilter",
  signature(x = "character", include = "character", exclude = "missing",
            envir = "missing"),
  definition = function(x, include) {
    return(classFilter(x, include, exclude = NA_character_, envir = sys.frame(-1)))
})

# fileTable -----------------------------------------------------------------------------------

#' Create empty `fileTable` for inputs and outputs
#'
#' Internal functions.
#' Returns an empty `fileTable` to be used with inputs and outputs.
#'
#' @param x  Not used (should be missing)
#'
#' @return An empty data.frame with structure needed for input/output `fileTable.`
#'
#' @keywords internal
#' @rdname fileTable
#'
setGeneric(".fileTableIn", function(x) {
  standardGeneric(".fileTableIn")
})

#' @rdname fileTable
setMethod(
  ".fileTableIn",
  signature = "missing",
  definition = function() {
    ft <- data.frame(
      file = character(0), fun = character(0), package = character(0),
      objectName = character(0), loadTime = numeric(0), loaded = logical(0),
      arguments = I(list()), intervals = numeric(0), stringsAsFactors = FALSE
    )
    return(ft)
  })

#' @rdname fileTable
.fileTableInCols <- colnames(.fileTableIn())

#' @rdname fileTable
.fileTableInDF <- .fileTableIn()

#' @rdname fileTable
setGeneric(".fileTableOut", function(x) {
  standardGeneric(".fileTableOut")
})

#' @rdname fileTable
setMethod(
  ".fileTableOut",
  signature = "missing",
  definition = function() {
    ft <- data.frame(
      file = character(0), fun = character(0), package = character(0),
      objectName = character(0), saveTime = numeric(0), saved = logical(0),
      arguments = I(list()), stringsAsFactors = FALSE
    )
    return(ft)
})

#' @rdname fileTable
.fileTableOutCols <- colnames(.fileTableOut())

#' @rdname fileTable
.fileTableOutDF <- .fileTableOut()

#' Simple wrapper around `data.table::rbindlist`
#'
#' This simply sets defaults to `fill = TRUE`, and `use.names = TRUE`.
#'
#' @param ... one or more `data.frame`, `data.table`, or `list` objects
#'
#' @return a `data.table` object
#'
#' @export
bindrows <- function(...) {
  # Deal with things like "trailing commas"
  rws <- try(list(...), silent = TRUE)
  if (any(grepl("argument is missing|bind_rows", rws))) {
    ll <- as.list(match.call(expand.dots = TRUE))
    nonEmpties <- unlist(lapply(ll, function(x) any(nchar(x) > 0)))
    eval(as.call(ll[nonEmpties]))
  } else if (is(rws, "try-error")) {
    stop(rws)
  } else {
    rbindlist(rws, fill = TRUE, use.names = TRUE)
  }
}

#' Extract the full file paths for R source code
#'
#' This can be used e.g., for Caching, to identify which files have changed.
#'
#' @inheritParams simInit
#'
#' @return character vector of file paths.
#'
#' @export
moduleCodeFiles <- function(paths, modules) {
  path.expand(c(dir(file.path(paths$modulePath, modules, "R"), full.names = TRUE),
    file.path(paths$modulePath, modules, paste0(modules, ".R"))))
}
