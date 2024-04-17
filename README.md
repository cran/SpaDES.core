<!-- badges: start -->
[![CRAN_Status_Badge](https://www.r-pkg.org/badges/version/SpaDES.core)](https://cran.r-project.org/package=SpaDES.core)
[![Downloads](https://cranlogs.r-pkg.org/badges/grand-total/SpaDES.core)](https://cran.r-project.org/package=SpaDES.core)
[![R build status](https://github.com/PredictiveEcology/SpaDES.core/workflows/R-CMD-check/badge.svg)](https://github.com/PredictiveEcology/SpaDES.core/actions)
<!-- badges: end -->

<img align="right" width="80" pad="20" src="https://github.com/PredictiveEcology/SpaDES/raw/master/man/figures/SpaDES.png">

# SpaDES.core

Core functionality for Spatial Discrete Event System (SpaDES).

This package provides the core framework for a discrete event system to 
    implement a complete data-to-decisions, reproducible workflow
    (e.g., McIntire et al. (2022) <https://doi.org/10.1111/ele.13994>,
    Barros et al. (2022) <https://doi.org/10.1111/2041-210X.14034>).
    The core components facilitate the development of modular pieces, 
    and enable the user to include additional functionality by running user-built modules.
    Includes conditional scheduling, restart after interruption, packaging of
    reusable modules, tools for developing arbitrary automated workflows,
    automated interweaving of modules of different temporal resolution,
    and tools for visualizing and understanding the within-project dependencies. 
    The suggested package 'NLMR' can be installed from the repository 
    (<https://PredictiveEcology.r-universe.dev>).

**Website:** [https://SpaDES-core.PredictiveEcology.org](https://SpaDES-core.PredictiveEcology.org)

**Wiki:** [https://github.com/PredictiveEcology/SpaDES/wiki](https://github.com/PredictiveEcology/SpaDES/wiki)

## Installation

### Current stable release

[![R build status](https://github.com/PredictiveEcology/SpaDES.core/workflows/R-CMD-check/badge.svg?branch=master)](https://github.com/PredictiveEcology/SpaDES.core/actions)
[![Codecov test coverage](https://codecov.io/gh/PredictiveEcology/SpaDES.core/branch/master/graph/badge.svg)](https://app.codecov.io/gh/PredictiveEcology/SpaDES.core?branch=master)

**Install from CRAN:**

```r
install.packages("SpaDES.core")
```

**Install from GitHub:**

```r
#install.packages("devtools")
library("devtools")
install_github("PredictiveEcology/SpaDES.core", dependencies = TRUE) # master
```

### Development version (unstable)

[![R build status](https://github.com/PredictiveEcology/SpaDES.core/workflows/R-CMD-check/badge.svg?branch=development)](https://github.com/PredictiveEcology/SpaDES.core/actions)
[![codecov](https://codecov.io/gh/PredictiveEcology/SpaDES.core/branch/development/graph/badge.svg?token=uz2mzVq1vJ)](https://app.codecov.io/gh/PredictiveEcology/SpaDES.core)
**Install from GitHub:**

```r
#install.packages("devtools")
library("devtools")
install_github("PredictiveEcology/SpaDES.core", ref = "development", dependencies = TRUE)
```

## Contributions

Please see `CONTRIBUTING.md` for information on how to contribute to this project.
