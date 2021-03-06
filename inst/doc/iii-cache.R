## ----setup, include = FALSE---------------------------------------------------
RFavailable <- isTRUE(require(SpaDES.tools) && require(RandomFields))

knitr::opts_chunk$set(eval = RFavailable)

options("spades.moduleCodeChecks" = FALSE,
        "spades.useRequire" = FALSE)

## ----examples, echo=TRUE, message=FALSE---------------------------------------
library(magrittr)
library(raster)
library(reproducible)
library(SpaDES.core)

mySim <- simInit(
  times = list(start = 0.0, end = 5.0),
  params = list(
    .globals = list(stackName = "landscape", burnStats = "testStats"),
    randomLandscapes = list(.plotInitialTime = NA),
    fireSpread = list(.plotInitialTime = NA)
  ),
  modules = list("randomLandscapes", "fireSpread"),
  paths = list(modulePath = system.file("sampleModules", package = "SpaDES.core"))
)

## ----spades-------------------------------------------------------------------
# compare caching ... run once to create cache
system.time({
  outSim <- spades(Copy(mySim), cache = TRUE, notOlderThan = Sys.time())
})

## ----spades-cached------------------------------------------------------------
# vastly faster 2nd time
system.time({
  outSimCached <- spades(Copy(mySim), cache = TRUE)
})
all.equal(outSim, outSimCached) 

## ----module-level, echo=TRUE--------------------------------------------------
# Module-level
params(mySim)$randomLandscapes$.useCache <- TRUE
system.time({
  randomSim <- spades(Copy(mySim), .plotInitialTime = NA,
                      notOlderThan = Sys.time(), debug = TRUE)
})

# vastly faster the second time
system.time({
  randomSimCached <- spades(Copy(mySim), .plotInitialTime = NA, debug = TRUE)
})

## ----test-module-level--------------------------------------------------------
layers <- list("DEM", "forestAge", "habitatQuality", "percentPine", "Fires")
same <- lapply(layers, function(l)
  identical(randomSim$landscape[[l]], randomSimCached$landscape[[l]]))
names(same) <- layers
print(same) # Fires is not same because all non-init events in fireSpread are not cached

## ----event-level, echo=TRUE---------------------------------------------------
params(mySim)$fireSpread$.useCache <- "init"
system.time({
  randomSim <- spades(Copy(mySim), .plotInitialTime = NA,
                      notOlderThan = Sys.time(), debug = TRUE)
})

# vastly faster the second time
system.time({
  randomSimCached <- spades(Copy(mySim), .plotInitialTime = NA, debug = TRUE)
})

## ----function-level, echo=TRUE------------------------------------------------
ras <- raster(extent(0, 1e3, 0, 1e3), res = 1)
system.time({
  map <- Cache(gaussMap, ras, cacheRepo = cachePath(mySim),
               notOlderThan = Sys.time())
})

# vastly faster the second time
system.time({
  mapCached <- Cache(gaussMap, ras, cacheRepo = cachePath(mySim))
})

all.equal(map, mapCached) 

## ----manual-cache-------------------------------------------------------------
cacheDB <- showCache(mySim)
# examine only the functions that have been cached
cacheDB[tagKey == "function"]

# get the RasterLayer that was produced with the gaussMap function:
map <- loadFromCache(cachePath(mySim), cacheId = cacheDB[tagValue == "gaussMap"]$cacheId)

clearPlot()
Plot(map)

## ---- eval=FALSE, echo=TRUE---------------------------------------------------
#  simInit() --> many .inputObjects calls
#  
#  spades() call --> many module calls --> many event calls --> many function calls

## ---- eval=FALSE, echo=TRUE---------------------------------------------------
#  parameters = list(
#    FireModule = list(.useCache = TRUE)
#  )
#  mySim <- simInit(..., params = parameters)
#  mySimOut <- spades(mySim)

