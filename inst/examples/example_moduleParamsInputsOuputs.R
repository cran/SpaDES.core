path <- system.file("sampleModules", package = "SpaDES.core")
sampleModules <- dir(path)

p <- moduleParams(sampleModules[3], path = path)
i <- moduleInputs(sampleModules[3], path = path)
o <- moduleOutputs(sampleModules[3], path = path)

#' \dontrun{
## easily include these tables in Rmd files using knitr
knitr::kable(p)
knitr::kable(i)
knitr::kable(o)
#' }
