# hIndexOverYears tutorial
Jose V. Die  
February 18, 2016  
  
This is a markdown tutorial on how to use the **hIndexOverYears** package. It is based on the overview of citations from a given author. **Data have to be obtained
from [Scoups](www.scopus.com) Database**.  
<br>  
  
### Corrections

Improvements and corrections to this document can be submitted on its [GitHub](https://github.com/jdieramon/hIndex/blob/master/tutorial.Rmd) in its [repository](https://github.com/jdieramon/hIndex).

### Data set
* Get the list of documents written by a given author and click on *View citation overview*.
![](figures/fig1.png)
  

* Set the Data range. Starting year corresponds to a year, so **h index = 0 for that author**. 
![](figures/fig2.png)
  
**Note for Senior Authors**: Scopus citation overview page can display up to 16 years. If your publication history goes back <2000, you will have to use **2000** as your starting year.  

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
?geth
?h.plot
?plot1cite
```

<br>  
Tidy Data  
Before we can work with further analysis, we want to make data tidy. The good thing is that Scopus keeps the same format for every citation overview, so data cleaning can be performed in one easy step. The function *clean()*  will read and clean the data for you.

**Load and clean data**

```r
dat <- clean("CTOExport.csv")
```
<br>

Now, the data set is ready to further analysis with the **hIndexOverYears** package. 
  
<br>

**Plot your h Index over years**  
You can use the *h.plot()* function on the tidy data to show the h Index evolution. If the starting year does not correspond with h=0, you can enter the h value as an argument:

```r
h.plot(dat, 2007, 2016, 0)
```
![](figures/Rplot.png)

<br>
You also can use the *plot1cite()* function to get a sense of how long it takes to get 1 citation for your most highly cited papers. 

```r
plot1cite(dat)
```
![](figures/fig5.png) 

<br>
You may want to list those publications. The output shows the Publication Year, Journal Title and the estimate of Months/1citation.

```r
format1cite(dat)
```

```
##    Publication Year                               Journal Title   sC
## 1              2010                                      Planta 1.22
## 2              2011  Journal of Agricultural and Food Chemistry 2.00
## 3              2008                     Analytical Biochemistry 3.10
## 4              2007 Physiological and Molecular Plant Pathology 3.38
## 5              2014       Environmental and Experimental Botany 3.43
## 6              2011                     Analytical Biochemistry 3.75
## 7              2012                          Molecular Breeding 4.80
## 8              2013  Journal of Agricultural and Food Chemistry 5.14
## 9              2009                               Weed Research 6.00
## 10             2013                          Molecular Breeding 6.00
## 11             2013                                    PLoS ONE 7.20
## 12             2012              Journal of Experimental Botany 9.60
```
  
Session information
```r
sessionInfo()
```
