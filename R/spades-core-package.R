##  SpaDES.core/R/SpaDES-core-package.R by Alex M Chubaty and Eliot J B McIntire
##  Copyright (C) 2015-2023 His Majesty the Queen in Right of Canada,
##  as represented by the Minister of Natural Resources Canada
##

#' Categorized overview of the `SpaDES.core` package
#'
#' \if{html}{\figure{SpaDES.png}{options: width=100 alt="SpaDES logo" style="float: right;"}}
#' \if{latex}{\figure{SpaDES.png}{options: width=0.5in}}
#'
#' @description
#' This package allows implementation a variety of simulation-type models,
#' with a focus on spatially explicit models.
#' The core simulation components are built upon a discrete event simulation
#' framework that facilitates modularity, and easily enables the user to
#' include additional functionality by running user-built simulation modules.
#' Included are numerous tools to visualize various spatial data formats,
#' as well as non-spatial data. Much work has been done to speed up the core
#' of the DES, with current benchmarking as low as 56 microseconds overhead for
#' each event (including scheduling, sorting event queue, spawning event etc.) or
#' 38 microseconds if there is no sorting (i.e., no sorting occurs under simple conditions).
#' Under most event conditions, therefore, the DES itself will contribute
#' very minimally compared to the content of the events, which may often be
#' milliseconds to many seconds each event.
#'
#' Bug reports: <https://github.com/PredictiveEcology/SpaDES.core/issues>
#'
#' Module repository: <https://github.com/PredictiveEcology/SpaDES-modules>
#'
#' Wiki: <https://github.com/PredictiveEcology/SpaDES/wiki>
#'
#' @section 1 Spatial discrete event simulation (`SpaDES`):
#'
#' A collection of top-level functions for doing spatial discrete event simulation.
#'
#' \subsection{1.1 Simulations}{
#'   There are two workhorse functions that initialize and run a simulation, and
#'   third function for doing multiple spades runs:
#'
#'   \tabular{ll}{
#'     [simInit()] \tab Initialize a new simulation\cr
#'     [spades()] \tab Run a discrete event simulation\cr
#'     `experiment` \tab In `SpaDES.experiment` package.
#'                                   Run multiple [spades()] calls\cr
#'     `experiment2` \tab In `SpaDES.experiment` package.
#'                                   Run multiple [spades()] calls\cr
#'   }
#' }
#'
#' \subsection{1.2 Events}{
#'   Within a module, important simulation functions include:
#'
#'   \tabular{ll}{
#'     [scheduleEvent()] \tab Schedule a simulation event\cr
#'     [scheduleConditionalEvent()] \tab Schedule a conditional simulation event\cr
#'     `removeEvent` \tab Remove an event from the simulation queue (not yet implemented)\cr
#'   }
#' }
#'
#' @section 2 The `simList` object class:
#'
#' The principle exported object class is the `simList`.
#' All `SpaDES` simulations operate on this object class.
#'
#' \tabular{ll}{
#'   [simList()] \tab The `simList` class\cr
#' }
#'
#' @section 3 `simList` methods:
#'
#' Collections of commonly used functions to retrieve or set slots (and their elements)
#' of a [simList()] object are summarized further below.
#'
#' \subsection{3.1 Simulation parameters}{
#'   \tabular{ll}{
#'      [globals()] \tab List of global simulation parameters.\cr
#'      [params()] \tab Nested list of all simulation parameter.\cr
#'      [P()] \tab Namespaced version of [params()]
#'                         (i.e., do not have to specify module name).\cr
#'   }
#' }
#'
#' \subsection{3.2 loading from disk, saving to disk}{
#'   \tabular{ll}{
#'      [inputs()] \tab List of loaded objects used in simulation. (advanced)\cr
#'      [outputs()] \tab List of objects to save during simulation. (advanced)\cr
#'   }
#' }
#'
#' \subsection{3.3 objects in the `simList`}{
#'   \tabular{ll}{
#'      [ls()], [objects()] \tab Names of objects referenced by the simulation environment.\cr
#'      [ls.str()] \tab List the structure of the `simList` objects.\cr
#'      [objs()] \tab List of objects referenced by the simulation environment.\cr
#'   }
#' }
#'
#' \subsection{3.4 Simulation paths}{
#'   Accessor functions for the `paths` slot and its elements.
#'   \tabular{ll}{
#'      [cachePath()] \tab Global simulation cache path.\cr
#'      [modulePath()] \tab Global simulation module path.\cr
#'      [inputPath()] \tab Global simulation input path.\cr
#'      [outputPath()] \tab Global simulation output path.\cr
#'      [rasterPath()] \tab Global simulation temporary raster path.\cr
#'      [paths()] \tab Global simulation paths (cache, modules, inputs, outputs, rasters).\cr
#'   }
#' }
#'
#' \subsection{3.5 Simulation times}{
#'   Accessor functions for the `simtimes` slot and its elements.
#'
#'   \tabular{ll}{
#'      [time()] \tab Current simulation time, in units of longest module.\cr
#'      [start()] \tab Simulation start time, in units of longest module.\cr
#'      [end()] \tab Simulation end time, in units of longest module.\cr
#'      [times()] \tab List of all simulation times (current, start, end), in units of longest module..\cr
#'   }
#' }
#'
#' \subsection{3.6 Simulation event queues}{
#'   Accessor functions for the `events` and `completed` slots.
#'   By default, the event lists are shown when the `simList` object is printed,
#'   thus most users will not require direct use of these methods.
#'
#'   \tabular{ll}{
#'      [events()] \tab Scheduled simulation events (the event queue). (advanced)\cr
#'      [current()] \tab Currently executing event. (advanced)\cr
#'      [completed()] \tab Completed simulation events. (advanced)\cr
#'      [elapsedTime()] \tab The amount of clock time that modules & events use\cr
#'   }
#' }
#'
#' \subsection{3.7 Modules, dependencies, packages}{
#'   Accessor functions for the `depends`, `modules`, and `.loadOrder` slots.
#'   These are included for advanced users.
#'
#'   \tabular{ll}{
#'      [depends()] \tab List of simulation module dependencies. (advanced)\cr
#'      [modules()] \tab List of simulation modules to be loaded. (advanced)\cr
#'      [packages()] \tab Vector of required R libraries of all modules. (advanced)\cr
#'   }
#' }
#'
#' \subsection{3.8 `simList` environment}{
#'   The [simList()] has a slot called `.xData` which is an environment.
#'   All objects in the `simList` are actually in this environment,
#'   i.e., the `simList` is not a `list`.
#'   In R, environments use pass-by-reference semantics, which means that copying
#'   a `simList` object using normal R assignment operation (e.g., `sim2 <- sim1`),
#'   will not copy the objects contained within the `.xData` slot.
#'   The two objects (`sim1` and `sim2`) will share identical objects
#'   within that slot. Sometimes, this not desired, and a true copy is required.
#'
#'   \tabular{ll}{
#'      [envir()] \tab Access the environment of the `simList` directly (advanced)\cr
#'      [copy()] \tab Deep copy of a `simList.` (advanced)\cr
#'   }
#' }
#'
#' \subsection{3.9 Checkpointing}{
#'   \tabular{lll}{
#'      Accessor method \tab Module \tab Description\cr
#'      [checkpointFile()] \tab `checkpoint` \tab Name of the checkpoint file. (advanced)\cr
#'      [checkpointInterval()] \tab `checkpoint` \tab The simulation checkpoint interval. (advanced)\cr
#'    }
#'  }
#'
#' \subsection{3.10 Progress Bar}{
#'   \tabular{lll}{
#'      [progressType()] \tab `.progress` \tab Type of graphical progress bar used. (advanced)\cr
#'      [progressInterval()] \tab `.progress` \tab Interval for the progress bar. (advanced)\cr
#'   }
#' }
#'
#' @section 4 Module operations:
#'
#' \subsection{4.1 Creating, distributing, and downloading modules}{
#'   Modules are the basic unit of `SpaDES`.
#'   These are generally created and stored locally, or are downloaded from remote
#'   repositories, including our
#'   [SpaDES-modules](https://github.com/PredictiveEcology/SpaDES-modules)
#'   repository on GitHub.
#'
#'   \tabular{ll}{
#'     [checksums()] \tab Verify (and optionally write) checksums for a module's data files.\cr
#'     [downloadModule()] \tab Open all modules nested within a base directory.\cr
#'     [getModuleVersion()] \tab Get the latest module version # from module repository.\cr
#'     [newModule()] \tab Create new module from template.\cr
#'     [newModuleDocumentation()] \tab Create empty documentation for a new module.\cr
#'     [openModules()] \tab Open all modules nested within a base directory.\cr
#'     [moduleMetadata()] \tab Shows the module metadata.\cr
#'     [zipModule()] \tab Zip a module and its associated files.\cr
#'   }
#' }
#'
#' \subsection{4.2 Module metadata}{
#'   Each module requires several items to be defined.
#'   These comprise the metadata for that module (including default parameter
#'   specifications, inputs and outputs), and are currently written at the top of
#'   the module's `.R` file.
#'
#'   \tabular{ll}{
#'     [defineModule()] \tab Define the module metadata\cr
#'     [defineParameter()] \tab Specify a parameter's name, value and set a default\cr
#'     [expectsInput()] \tab Specify an input object's name, class, description, `sourceURL` and other specifications\cr
#'     [createsOutput()] \tab Specify an output object's name, class, description and other specifications\cr
#'   }
#'
#'   There are also accessors for many of the metadata entries:
#'   \tabular{ll}{
#'     [timeunit()] \tab Accesses metadata of same name\cr
#'     [citation()] \tab Accesses metadata of same name\cr
#'     [documentation()] \tab Accesses metadata of same name\cr
#'     [reqdPkgs()] \tab Accesses metadata of same name\cr
#'     [inputObjects()] \tab Accesses metadata of same name\cr
#'     [outputObjects()] \tab Accesses metadata of same name\cr
#'   }
#' }
#'
#' \subsection{4.3 Module dependencies}{
#'   Once a set of modules have been chosen, the dependency information is automatically
#'   calculated once `simInit` is run. There are several functions to assist with dependency
#'   information:
#'
#'   \tabular{ll}{
#'     [depsEdgeList()] \tab Build edge list for module dependency graph\cr
#'     [depsGraph()] \tab Build a module dependency graph using `igraph`\cr
#'   }
#' }
#'
#' @section 5 Module functions:
#'
#' *A collection of functions that help with making modules can be found in
#' the suggested `SpaDES.tools` package, and are summarized below.*
#'
#' \subsection{5.1 Spatial spreading/distances methods}{
#'   Spatial contagion is a key phenomenon for spatially explicit simulation models.
#'   Contagion can be modelled using discrete approaches or continuous approaches.
#'   Several `SpaDES.tools` functions assist with these:
#'
#'   \tabular{ll}{
#'     [SpaDES.tools::adj()] \tab An optimized (i.e., faster) version of [terra::adjacent()]\cr
#'     [SpaDES.tools::cir()] \tab Identify pixels in a circle around a [`SpatialPoints*()`][sp::SpatialPoints-class] object\cr
#'     [`directionFromEachPoint()`][SpaDES.tools::distanceFromEachPoint] \tab Fast calculation of direction and distance surfaces\cr
#'     [SpaDES.tools::distanceFromEachPoint()] \tab Fast calculation of distance surfaces\cr
#'     [SpaDES.tools::rings()] \tab Identify rings around focal cells (e.g., buffers and donuts)\cr
#'     [SpaDES.tools::spokes()] \tab Identify outward radiating spokes from initial points\cr
#'     [SpaDES.tools::spread()] \tab Contagious cellular automata\cr
#'     [SpaDES.tools::spread2()] \tab Contagious cellular automata, different algorithm, more robust\cr
#'     [SpaDES.tools::wrap()] \tab Create a torus from a grid\cr
#'   }
#' }
#'
#' \subsection{5.2 Spatial agent methods}{
#'   Agents have several methods and functions specific to them:
#'
#'   \tabular{ll}{
#'     [SpaDES.tools::crw()] \tab Simple correlated random walk function\cr
#'     [SpaDES.tools::heading()] \tab Determines the heading between `SpatialPoints*`\cr
#'     [quickPlot::makeLines()] \tab Makes `SpatialLines` object for, e.g., drawing arrows\cr
#'     [`move()`][SpaDES.tools::move] \tab A meta function that can currently only take "crw"\cr
#'     [`specificNumPerPatch()`][SpaDES.tools::specificNumPerPatch] \tab Initiate a specific number of agents per patch\cr
#'   }
#' }
#'
#' \subsection{5.3 GIS operations}{
#'   In addition to the vast amount of GIS operations available in R (mostly from
#'   contributed packages such as `sf`, `terra`, (also `sp`, `raster`), `maps`, `maptools`
#'   and many others), we provide the following GIS-related functions:
#'
#'   \tabular{ll}{
#'     [equalExtent()] \tab Assess whether a list of extents are all equal\cr
#'   }
#' }
#'
#' \subsection{5.4 'Map-reduce'--type operations}{
#'   These functions convert between reduced and mapped representations of the same data.
#'   This allows compact representation of, e.g., rasters that have many individual pixels
#'   that share identical information.
#'
#'   \tabular{ll}{
#'     [SpaDES.tools::rasterizeReduced()] \tab Convert reduced representation to full raster.\cr
#'   }
#' }
#'
#' \subsection{5.5 Colours in `Raster*` objects}{
#'   We likely will not want the default colours for every map.
#'   Here are several helper functions to add to, set and get colours of `Raster*` objects:
#'
#'   \tabular{ll}{
#'     [`setColors()`][quickPlot::setColors] \tab Set colours for plotting `Raster*` objects\cr
#'     [getColors()] \tab Get colours in a `Raster*` objects\cr
#'     [divergentColors()] \tab Create a colour palette with diverging colours around a middle\cr
#'   }
#' }
#'
#' \subsection{5.6 Random Map Generation}{
#'   It is often useful to build dummy maps with which to build simulation models before all data are available.
#'   These dummy maps can later be replaced with actual data maps.
#'
#'   \tabular{ll}{
#'     [SpaDES.tools::neutralLandscapeMap()] \tab Creates a random map using Gaussian random fields\cr
#'     [SpaDES.tools::randomPolygons()] \tab Creates a random polygon with specified number of classes\cr
#'   }
#' }
#'
#' \subsection{5.7 Checking for the existence of objects}{
#'   `SpaDES` modules will often require the existence of objects in the `simList`.
#'   These are helpers for assessing this:
#'
#'   \tabular{ll}{
#'     [checkObject()] \tab Check for a existence of an object within a `simList` \cr
#'     [reproducible::checkPath()] \tab Checks the specified filepath for formatting consistencies\cr
#'   }
#' }
#'
#' \subsection{5.8 SELES-type approach to simulation}{
#'   These functions are essentially skeletons and are not fully implemented.
#'   They are intended to make translations from SELES (https://www.gowlland.ca/).
#'   You must know how to use SELES for these to be useful:
#'
#'   \tabular{ll}{
#'     [`agentLocation()`][SpaDES.tools::agentLocation] \tab Agent location\cr
#'     [SpaDES.tools::initiateAgents()] \tab Initiate agents into a `SpatialPointsDataFrame`\cr
#'     [`numAgents()`][SpaDES.tools::numAgents] \tab Number of agents\cr
#'     [`probInit()`][SpaDES.tools::probInit] \tab Probability of initiating an agent or event\cr
#'     [`transitions()`][SpaDES.tools::transitions] \tab Transition probability\cr
#'   }
#' }
#'
#' \subsection{5.9 Miscellaneous}{
#'   Functions that may be useful within a `SpaDES` context:
#'
#'   \tabular{ll}{
#'     [SpaDES.tools::inRange()] \tab Test whether a number lies within range `[a,b]`\cr
#'     [layerNames()] \tab Get layer names for numerous object classes\cr
#'     [numLayers()] \tab Return number of layers\cr
#'     [paddedFloatToChar()] \tab Wrapper for padding (e.g., zeros) floating numbers to character\cr
#'   }
#' }
#'
#' @section 6 Caching simulations and simulation components:
#'
#' *Simulation caching uses the `reproducible` package.*
#'
#' Caching can be done in a variety of ways, most of which are up to the module developer.
#' However, the one most common usage would be to cache a simulation run.
#' This might be useful if a simulation is very long, has been run once, and the
#' goal is just to retrieve final results.
#' This would be an alternative to manually saving the outputs.
#'
#' See example in [spades()], achieved by using `cache = TRUE` argument.
#'
#' \tabular{ll}{
#'   [reproducible::Cache()] \tab Caches a function, but often accessed as argument in [spades()]\cr
#'   [reproducible::showCache()] \tab Shows information about the objects in the cache\cr
#'   [reproducible::clearCache()] \tab Removes objects from the cache\cr
#'   [reproducible::keepCache()] \tab Keeps only the objects described\cr
#' }
#'
#' A module developer can build caching into their module by creating cached versions of their
#' functions.
#'
#' @section 7 Plotting:
#'
#' **Much of the underlying plotting functionality is provided by \pkg{quickPlot}.**
#'
#' There are several user-accessible plotting functions that are optimized for modularity
#' and speed of plotting:
#'
#' Commonly used:
#' \tabular{ll}{
#'   [Plot()] \tab The workhorse plotting function\cr
#' }
#'
#' Simulation diagrams:
#' \tabular{ll}{
#'   [eventDiagram()] \tab Gantt chart representing the events in a completed simulation.\cr
#'   [moduleDiagram()] \tab Network diagram of simplified module (object) dependencies.\cr
#'   [objectDiagram()] \tab Sequence diagram of detailed object dependencies.\cr
#' }
#'
#' Other useful plotting functions:
#' \tabular{ll}{
#'   [clearPlot()] \tab Helpful for resolving many errors\cr
#'   [clickValues()] \tab Extract values from a raster object at the mouse click location(s)\cr
#'   [clickExtent()] \tab Zoom into a raster or polygon map that was plotted with [Plot()]\cr
#'   [clickCoordinates()] \tab Get the coordinates, in map units, under mouse click\cr
#'   [dev()] \tab Specify which device to plot on, making a non-RStudio one as default\cr
#'   [newPlot()] \tab Open a new default plotting device\cr
#'   [rePlot()] \tab Re-plots all elements of device for refreshing or moving plot\cr
#' }
#'
#' @section 8 File operations:
#'
#' In addition to R's file operations, we have added several here to aid in bulk
#' loading and saving of files for simulation purposes:
#'
#' \tabular{ll}{
#'   [loadFiles()] \tab Load simulation objects according to a file list\cr
#'   [rasterToMemory()] \tab Read a raster from file to RAM\cr
#'   [saveFiles()] \tab Save simulation objects according to outputs and parameters\cr
#' }
#'
#' @section 9 Sample modules included in package:
#'
#' Several dummy modules are included for testing of functionality.
#' These can be found with `file.path(find.package("SpaDES.core"), "sampleModules")`.
#'
#' \tabular{ll}{
#'   `randomLandscapes` \tab Imports, updates, and plots several raster map layers\cr
#'   `caribouMovement` \tab A simple agent-based (a.k.a., individual-based) model\cr
#'   `fireSpread` \tab A simple model of a spatial spread process\cr
#' }
#'
#' @section 10 Package options:
#'
#' `SpaDES` packages use the following [options()] to configure behaviour:
#'
#' \itemize{
#'   \item `spades.browserOnError`: If `TRUE`, the default, then any
#'   error rerun the same event with `debugonce` called on it to allow editing
#'   to be done. When that browser is continued (e.g., with 'c'), then it will save it
#'   reparse it into the `simList` and rerun the edited version. This may allow a spades
#'   call to be recovered on error, though in many cases that may not be the correct
#'   behaviour. For example, if the `simList` gets updated inside that event in an iterative
#'   manner, then each run through the event will cause that iteration to occur.
#'   When this option is `TRUE`, then the event will be run at least 3 times: the
#'   first time makes the error, the second time has `debugonce` and the third time
#'   is after the error is addressed. `TRUE` is likely somewhat slower.
#'
#'   \item `reproducible.cachePath`: The default local directory in which to
#'   cache simulation outputs.
#'   Default is a temporary directory (typically `/tmp/RtmpXXX/SpaDES/cache`).
#'
#'   \item `spades.inputPath`: The default local directory in which to
#'   look for simulation inputs.
#'   Default is a temporary directory (typically `/tmp/RtmpXXX/SpaDES/inputs`).
#'
#'   \item `spades.debug`: The default debugging value `debug`
#'   argument in `spades()`. Default is `TRUE`.
#'
#'   \item `spades.lowMemory`: If true, some functions will use more memory
#'     efficient (but slower) algorithms. Default `FALSE`.
#'
#'   \item `spades.moduleCodeChecks`: Should the various code checks be run
#'   during `simInit`. These are passed to `codetools::checkUsage()`.
#'   Default is given by the function, plus these :`list(suppressParamUnused = FALSE,
#'   suppressUndefined = TRUE, suppressPartialMatchArgs = FALSE, suppressNoLocalFun = TRUE,
#'   skipWith = TRUE)`.
#'
#'   \item `spades.modulePath`: The default local directory where modules
#'     and data will be downloaded and stored.
#'     Default is a temporary directory (typically `/tmp/RtmpXXX/SpaDES/modules`).
#'
#'   \item `spades.moduleRepo`: The default GitHub repository to use when
#'     downloading modules via `downloadModule`.
#'     Default `"PredictiveEcology/SpaDES-modules"`.
#'
#'   \item `spades.nCompleted`: The maximum number of completed events to
#'     retain in the `completed` event queue. Default `1000L`.
#'
#'   \item `spades.outputPath`: The default local directory in which to
#'   save simulation outputs.
#'   Default is a temporary directory (typically `/tmp/RtmpXXX/SpaDES/outputs`).
#'
#'   \item `spades.recoveryMode`: If this a numeric greater than 0 or TRUE, then the
#'   discrete event simulator will take a snapshot of the objects in the `simList`
#'   that might change (based on metadata `outputObjects` for that module), prior to
#'   initiating every event. This will allow the
#'   user to be able to recover in case of an error or manual interruption (e.g., `Esc`).
#'   If this is numeric, a copy of that number of "most recent events" will be
#'   maintained so that the user can recover and restart more than one event in the past,
#'   i.e., redo some of the "completed" events.
#'   Default is `TRUE`, i.e., it will keep the state of the `simList`
#'   at the start of the current event. This can be recovered with `restartSpades`
#'   and the differences can be seen in a hidden object in the stashed `simList.`
#'   There is a message which describes how to find that.
#'
#'   \item `spades.switchPkgNamespaces`: Should the search path be modified
#'     to ensure a module's required packages are listed first?
#'     Default `FALSE` to keep computational overhead down. If `TRUE`,
#'     there should be no name conflicts among package objects,
#'     but it is much slower, especially if the events are themselves fast.
#'
#'   \item `spades.tolerance`: The default tolerance value used for floating
#'     point number comparisons. Default `.Machine$double.eps^0.5`.
#'
#'   \item `spades.useragent`: The default user agent to use for downloading
#'     modules from GitHub.com. Default `"https://github.com/PredictiveEcology/SpaDES"`.
#' }
#'
#' @seealso [spadesOptions()]
#'
#' @import igraph
#' @import methods
#' @rdname SpaDES.core-package
"_PACKAGE"
