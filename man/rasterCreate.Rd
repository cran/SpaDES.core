% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/load.R
\name{rasterCreate}
\alias{rasterCreate}
\alias{rasterCreate.default}
\alias{rasterCreate.RasterBrick}
\alias{rasterCreate.RasterLayer}
\alias{rasterCreate.RasterStack}
\alias{rasterCreate.Raster}
\title{Simple wrapper to load any \code{Raster*} object
This wraps either \code{raster::raster}, \code{raster::stack},
or \code{raster::brick}, allowing a single function to be used
to create a new object of the same class as a template.}
\usage{
rasterCreate(x, ...)

\method{rasterCreate}{default}(x, ...)

\method{rasterCreate}{RasterBrick}(x, ...)

\method{rasterCreate}{RasterLayer}(x, ...)

\method{rasterCreate}{RasterStack}(x, ...)

\method{rasterCreate}{Raster}(x, ...)
}
\arguments{
\item{x}{An object, notably a \code{Raster*} object. All others will simply
be passed through with no effect.}

\item{...}{Passed to \code{raster::raster}, \code{raster::stack},
or \code{raster::brick}}
}
\description{
Simple wrapper to load any \code{Raster*} object
This wraps either \code{raster::raster}, \code{raster::stack},
or \code{raster::brick}, allowing a single function to be used
to create a new object of the same class as a template.
}
\details{
A new (empty) object of same class as the original.
}
\section{Methods (by class)}{
\itemize{
\item \code{default}: Simply passes through argument with no effect

\item \code{RasterBrick}: Uses \code{raster::brick}

\item \code{RasterLayer}: Uses \code{raster::raster}

\item \code{RasterStack}: Uses \code{raster::stack}

\item \code{Raster}: Uses \code{raster::raster} when one of the other,
less commonly used \code{Raster*} classes, e.g., \code{RasterLayerSparse}
}}

