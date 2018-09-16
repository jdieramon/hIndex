---
title: "hIndexOverYears tutorial"
author: "Jose V. Die"
date: "February 18, 2016"
output: 
  html_document: 
    keep_md: yes
---
  
This is a markdown tutorial for the **hIndexOverYears** package. It is based on the overview of citations from a given author. **Data has to be obtained from [Scoups](www.scopus.com) Database**.  
<br>  
  
### Corrections

Improvements and corrections to this document can be submitted on its [GitHub](https://github.com/jdieramon/hIndex/blob/master/tutorial.Rmd) in its [repository](https://github.com/jdieramon/hIndex).

### Data set
* Get the list of documents written by a given author and click on *View citation overview*.
![](figures/fig1.png)
  

* Set Data range. Starting year corresponds to the beginnning publication record, so that author has **h index = 0**. 
![](figures/fig2.png)
  
* Export the citation overview to a spreedsheet  
![](figures/fig3.png)

***
  
### Install the hIndexOverYears from Github
**Step1**. You need to install the [devtools](https://github.com/hadley/devtools) package.

```r
install.packages("devtools")
```
<br>
**Step2**. Load the devtools package.

```r
library(devtools)
```
<br>
**Step3**. Install the **hIndexOverYears** package. 

```r
install_github("jdieramon/hIndex")
```

***
  
### Usage
Load the package

```r
library(hIndexOverYears)
```

<br>
Let´s take a look at the documentation of the package.

```r
library(help=hIndexOverYears)
```
![](figures/fig4.png)

<br>
You can see the code for the functions:

```r
?h.plot
?get1cite
```

### Tidy Data  
Before we start the analysis, we want to make the data tidy. The good thing is that Scopus keeps the same format for every citation overview, so data cleaning can be performed in one easy step. The function `clean` will read and clean the data for you.

**Load and clean data**

```r
dat <- clean("CTOExport.csv")
```

Now, the dataset is ready for further analysis.  
    
  
### Plot the h Index  
You can also use the `h.plot` function on the tidy data to show the h Index evolution over years. If the starting year does not correspond with h=0, you can enter the h value as an argument:

```r
h.plot(dat, 2007, 2018, 0)
```
![](figures/Rplot.png)

<br>
You may also want to use the `get1cite`function to list your most highly cited papers (top10) and get a sense of how long it takes to get then 1 citation. 
The function shows by default your top10 cited papers, but you can give the number of papers as an argument. It shows the average time (in months) per 1 cite. 



```r
get1cite(dat)
```

```
##    Year                                     Journal avgMonth
## 1  2010                                      Planta     0.98
## 2  2011  Journal of Agricultural and Food Chemistry     2.10
## 3  2014       Environmental and Experimental Botany     2.53
## 4  2008                     Analytical Biochemistry     2.67
## 5  2013                                    PLoS ONE     3.53
## 6  2007 Physiological and Molecular Plant Pathology     3.88
## 7  2013  Journal of Agricultural and Food Chemistry     4.00
## 8  2017                                    PLoS ONE     4.00
## 9  2012                          Molecular Breeding     4.24
## 10 2011                     Analytical Biochemistry     4.42
## 11 2012              Journal of Experimental Botany     4.80
## 12 2009                               Weed Research     5.14
## 13 2013                          Molecular Breeding     5.45
## 14 2016       Environmental and Experimental Botany     8.00
## 15 2011                     Analytical Biochemistry     9.33
```


<br>


  Session information

```r
sessionInfo()
```

```
## R version 3.3.2 (2016-10-31)
## Platform: x86_64-apple-darwin13.4.0 (64-bit)
## Running under: macOS  10.13.2
## 
## locale:
## [1] es_ES.UTF-8/es_ES.UTF-8/es_ES.UTF-8/C/es_ES.UTF-8/es_ES.UTF-8
## 
## attached base packages:
## [1] stats     graphics  grDevices utils     datasets  methods   base     
## 
## other attached packages:
## [1] bindrcpp_0.2        hIndexOverYears_1.0 ggplot2_2.2.1      
## [4] dplyr_0.7.4        
## 
## loaded via a namespace (and not attached):
##  [1] Rcpp_0.12.16     knitr_1.20       bindr_0.1.1      magrittr_1.5    
##  [5] munsell_0.4.3    colorspace_1.3-2 R6_2.2.2         rlang_0.2.0     
##  [9] plyr_1.8.4       stringr_1.3.0    tools_3.3.2      grid_3.3.2      
## [13] gtable_0.2.0     htmltools_0.3.6  lazyeval_0.2.1   yaml_2.1.18     
## [17] assertthat_0.2.0 rprojroot_1.3-2  digest_0.6.15    tibble_1.4.2    
## [21] glue_1.2.0       evaluate_0.10.1  rmarkdown_1.9    stringi_1.1.7   
## [25] pillar_1.2.1     scales_0.5.0     backports_1.1.2  pkgconfig_2.0.1
```
