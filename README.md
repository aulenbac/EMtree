
<!-- README.md is generated from README.Rmd. Please edit that file -->
EMtree
======

[![Travis build status](https://travis-ci.org/Rmomal/EMtree.svg?branch=master)](https://travis-ci.org/Rmomal/EMtree) [![Codecov test coverage](https://codecov.io/gh/Rmomal/EMtree/branch/master/graph/badge.svg)](https://codecov.io/gh/Rmomal/EMtree?branch=master) [![DOI](https://zenodo.org/badge/166967948.svg)](https://zenodo.org/badge/latestdoi/166967948)

> EMtree infers interaction networks from abundance data. It uses averages over spanning trees within a Poisson log-Normal Model ([PLNmodels](https://github.com/jchiquet/PLNmodels%3E)), and involves plotting funcitonalities (using `ggraph` and `tydigraph`).

Installation
------------

You can install the development version of EMtree:

``` r
devtools::install_github("Rmomal/EMtree")
```

Example with Fatala river fishes
--------------------------------

This is a basic example which shows you how to infer a network, using Barans95 data from the `ade4` package.

### Data

``` r
library(ade4)
library(tidyverse)
data(baran95)
counts = as.matrix(baran95$fau)
covar = as_tibble(baran95$plan)

n = nrow(counts)
p = ncol(counts)
```

``` r
head(counts)
#>   AMA CAS CHI CHL CJO CST CTR CWA CYS DAF EFI ELA GDE GME HFA HFO IAF LFA
#> 1   0   2   0   3   0   0   0   0   0   0  71   1   5   6   0   0   7   3
#> 2   0   1   0   0   0   0   0   0   0   0 118   2   3   0   0   0   8   1
#> 3   0   2   0   3   0   0   0   0   0   0  69   0   6   2   0   0   8   3
#> 4   0   0   0   2   0   0   0   0   0   0  56   0   0   0   0   0   1   0
#> 5   0   0   0   0   0   0   0   0   3   0   0   1   1   0   0   0   2   2
#> 6   0   0   0   0   0   0   0   0   5   0   0   0   2   0   0   0   0   0
#>   LGR LNI PAA PBR PEL PJU PLE PMO POQ PPA PQQ PTY SEB TIN TLE
#> 1   3   0   0   5   2   9  26   0   4   0   0   0  22   0   2
#> 2   7   0   0   0   0   0 113   0   1   0   0   1  18   0   1
#> 3   0   0   0   1   0   3   0   0   1   0   0   0   3   0   0
#> 4   2   0   0   0   0   0   0   0   0   0   0   0  15   0   0
#> 5   5   0   0   0   3   0   0   0   4   0   0   3   0   0   0
#> 6   9   0   0   2   4   4   0   2   0   0   0   1   0   0   0
head(covar)
#> # A tibble: 6 x 2
#>   date  site 
#>   <fct> <fct>
#> 1 apr93 km03 
#> 2 apr93 km03 
#> 3 apr93 km03 
#> 4 apr93 km03 
#> 5 apr93 km17 
#> 6 apr93 km17
```

### Fit PLN model

This creates a `PLNmodels` object

``` r
library(PLNmodels)
model<-PLN(counts ~ covar$site)
#> 
#>  Initialization...
#>  Adjusting a PLN model with full covariance model
#>  Post-treatments...
#>  DONE!
```

### Run EMtree function

``` r
library(EMtree)
set.seed(3)
output<-EMtree(model,  maxIter = 10, plot=TRUE)
#> 
#> Likelihoods: 81.60106 , 81.68395 , 81.684 ,
```

<img src="man/figures/README-output-1.png" style="display: block; margin: auto;" />

    #> 
    #> Convergence took 0.4 secs  and  3  iterations.
    #> Likelihood difference = 5.399854e-05 
    #> Betas difference = 2.305752e-09
    str(output)
    #> List of 5
    #>  $ edges_prob  : num [1:33, 1:33] 0.00 6.78e-05 3.17e-03 7.09e-02 2.84e-03 ...
    #>  $ edges_weight: num [1:33, 1:33] 0 0.000946 0.000946 0.000947 0.000946 ...
    #>  $ logpY       : num [1:3] 81.6 81.7 81.7
    #>  $ maxIter     : num 3
    #>  $ timeEM      : 'difftime' num 0.398315906524658
    #>   ..- attr(*, "units")= chr "secs"

### Foster robustness with resampling :

``` r
library(parallel)
resample_output<-ResampleEMtree(counts=counts, covar_matrix = covar$site , S=5, maxIter=10,cond.tol=1e-8, cores=1)
#> 
#> S= 1  [1] 0.7236842
#> 
#> Convergence took 0.23 secs  and  5  iterations.  0.7236842
#> S= 2  [1] 0.6052632
#> 
#> Convergence took 0.16 secs  and  3  iterations.  0.6052632
#> S= 3  [1] 0.6973684
#> 
#> Convergence took 0.32 secs  and  7  iterations.  0.6973684
#> S= 4  [1] 0.7894737
#> 
#> Convergence took 0.13 secs  and  3  iterations.  0.7894737
#> S= 5  [1] 0.8815789
#> 
#> Convergence took 0.26 secs  and  6  iterations.  0.8815789
str(resample_output)
#> List of 3
#>  $ Pmat   : num [1:5, 1:528] 3.86e-03 5.74e-03 4.27e-04 5.08e-05 2.41e-05 ...
#>  $ maxIter: num [1:5] 5 3 7 3 6
#>  $ times  : 'difftime' num [1:5] 0.230384111404419 0.160486936569214 0.315670013427734 0.13437294960022 ...
#>   ..- attr(*, "units")= chr "secs"
```

### Several models with resampling :

``` r
library(parallel)
tested_models=list(1,2,c(1,2))
models_names=c("date","site","date + site")
compare_output<-ComparEMtree(counts, covar_matrix=covar, models=tested_models, m_names=models_names, Pt=0.15,  S=3, maxIter=5,cond.tol=1e-8,cores=1)
#> 
#> model  date
#> S= 1  
#> Convergence took 0.16 secs  and  3  iterations. 
#> S= 2  
#> Convergence took 0.19 secs  and  4  iterations. 
#> S= 3  
#> Convergence took 0.18 secs  and  4  iterations. 
#> model  site
#> S= 1  
#> Convergence took 0.23 secs  and  5  iterations. 
#> S= 2  
#> Convergence took 0.15 secs  and  3  iterations. 
#> S= 3  
#> Convergence took 0.21 secs  and  5  iterations. 
#> model  date + site
#> S= 1  
#> Convergence took 0.22 secs  and  5  iterations. 
#> S= 2  
#> Convergence took 0.14 secs  and  3  iterations. 
#> S= 3  
#> Convergence took 0.22 secs  and  5  iterations.

str(compare_output)
#> Classes 'tbl_df', 'tbl' and 'data.frame':    1584 obs. of  4 variables:
#>  $ node1 : chr  "1" "1" "2" "1" ...
#>  $ node2 : chr  "2" "3" "3" "4" ...
#>  $ model : chr  "date" "date" "date" "date" ...
#>  $ weight: num  0 0 0 0 0 ...
```

### Graphics

#### From `EMtree` output

Simple network:

``` r
library(ggraph)
library(tidygraph)
library(viridis)

set.seed(200)
edges_prob<- output$edges_prob
edges_prob[edges_prob<2/p]<-0
draw_network(edges_prob,title="Site", pal="dodgerblue3", layout="nicely",curv=0.1)$G
```

<img src="man/figures/README-unnamed-chunk-5-1.png" style="display: block; margin: auto;" />

#### From `ResampleEMtree` output

``` r

df<-freq_selec(resample_output$Pmat,Pt=2/p+0.1)

draw_network(df,"Site", layout="nicely")$G
```

<img src="man/figures/README-unnamed-chunk-6-1.png" style="display: block; margin: auto;" />

``` r

df[which(df<1e-6)]=0
draw_network(df,"Site", layout="nicely")$G
```

<img src="man/figures/README-unnamed-chunk-6-2.png" style="display: block; margin: auto;" />

``` r
draw_network(df,"Site", layout="nicely")$graph_data
#> # A tbl_graph: 33 nodes and 88 edges
#> #
#> # An undirected simple graph with 1 component
#> #
#> # Node Data: 33 x 8 (active)
#>     btw bool_btw bool_deg   deg title  name label finalcolor
#>   <dbl> <lgl>    <lgl>    <dbl> <chr> <int> <chr> <lgl>     
#> 1  16.3 FALSE    TRUE         8 Site      1 ""    FALSE     
#> 2  11   FALSE    TRUE         4 Site      2 ""    FALSE     
#> 3   2   FALSE    TRUE         2 Site      3 ""    FALSE     
#> 4   0   FALSE    TRUE         4 Site      4 ""    FALSE     
#> 5   0   FALSE    TRUE         3 Site      5 ""    FALSE     
#> 6  23.5 FALSE    TRUE         4 Site      6 ""    FALSE     
#> # … with 27 more rows
#> #
#> # Edge Data: 88 x 6
#>    from    to weight btw.weights neibs title
#>   <int> <int>  <dbl>       <dbl> <lgl> <chr>
#> 1     1     4    0.2        1.79 FALSE Site 
#> 2     1     7    0.4        1.25 FALSE Site 
#> 3     1     8    0.2        1.79 FALSE Site 
#> # … with 85 more rows
```

#### Facet for plotting several models in one shot

Comparing network by eye is difficult. In particular, choosing the right layout to do so is often troublesome. Here by default, the circle layout is used so that differences in density are easily seen.

``` r
compar_graphs(compare_output,alpha=TRUE)$G
```

<img src="man/figures/README-unnamed-chunk-7-1.png" style="display: block; margin: auto;" />

However, the user can decide another layout. The nodes position is preserved along the networks.

``` r
compar_graphs(compare_output,alpha=FALSE, layout="nicely", curv=0.1, base_model="site")$G
```

<img src="man/figures/README-unnamed-chunk-8-1.png" style="display: block; margin: auto;" />
