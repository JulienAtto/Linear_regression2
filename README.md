# Multiple Linear Regression

[https://julienatto.github.io/Linear_regression2/](https://julienatto.github.io/Linear_regression2/)




```r
#loading libraries to use
library(dplyr)
library(datasets) #for mtcars data
library(ggplot2)
library(scatterplot3d)
library(stringr)
library(magick)
```

Multiple linear regression is a statistical method for finding a linear relationship between $n$ explanatory variables $X_1, X_2, \cdots, X_n$ $(n\geq 2)$ and a variable to be explained $y$:
\[y= \theta_0 + \theta_1 X_1 + \theta_2 X_2 + \cdots + \theta_n X_n.\]

# Data preparation and visualisation

```r
#Loading mtcars data
data(mtcars)
```

The data **mtcars** in R package **datasets** was extracted from the 1974 Motor Trend US magazine, and comprises fuel consumption and 10 aspects of automobile design and performance for 32 automobiles (1973–74 models). We will use the following variables:

* mpg: Miles(US) gallon

* disp: Displacement (cu.in.)

* wt: Weight(100o lbs).


## Visualization of 10 rows chosen randomly among the 32 observations

```r
set.seed(1234)
mtcars%>%
  mutate(carnames=rownames(mtcars))%>%
  filter(carnames%in%sample(carnames,10))%>%
  select(mpg,disp,wt)
```

```
##                      mpg  disp    wt
## Hornet Sportabout   18.7 360.0 3.440
## Valiant             18.1 225.0 3.460
## Merc 230            22.8 140.8 3.150
## Merc 450SE          16.4 275.8 4.070
## Cadillac Fleetwood  10.4 472.0 5.250
## Lincoln Continental 10.4 460.0 5.424
## Dodge Challenger    15.5 318.0 3.520
## Fiat X1-9           27.3  79.0 1.935
## Lotus Europa        30.4  95.1 1.513
## Volvo 142E          21.4 121.0 2.780
```


## Graph

```r
x =mtcars$disp 
y =mtcars$wt
z =mtcars$mpg

scatterplot3d::scatterplot3d(x, y,z, pch = 19, type = "h", color = "red",
                     main = "Miles/(US) gallon as a function of engine Displacement and car Weight",xlab = "Displacement (cu.in.)",ylab = "Weight (x1000 lbs)",zlab = "Miles/(US) gallon",
                     grid = T, box = F,  
                     mar = c(2.5, 2.5, 2, 1.5), angle = 60)
```

![](index_files/figure-html/graph-1.png)<!-- -->

# Linear regresson using Gradient Descent
## Computation of the parameters


```r
#X and y
X<-with(mtcars,cbind(disp,wt))

y=with(mtcars,cbind(mpg))

# initializing fitting parameters
theta = cbind(numeric(3)) 

#loading  some functions... 
source("myfunctions.R")

##############################################################
  # Running Gradient Descent and plotting cost as function of number of iterations for some values of the learning rate.

  ALPHA<-c(0.3,0.1,0.03,0.01)
  COL<-c("red","blue","green","yellow")
  nb_iter<-NULL #initialiation of vector containing number of iterations for each value of alpha
  out<-list()
  Cost_by_iter<-list()
  
  for(i in 1:length(ALPHA)){
    # Initializing  theta and running Gradient Descent 
    theta = matrix(0,3)
    Grad_Desc<- Grad_Desc_fct(X, y, theta, alpha = ALPHA[i], max_iter=10000)
    theta<-Grad_Desc$theta
    Cost_by_iter[[i]]<-Grad_Desc$Cost_by_iter
    nb_iter=append(nb_iter,Grad_Desc$nb_iter)
    out[[i]]<-theta 
    } # end of for(i in 1:length(ALPHA))
```

```
## [1] "alpha= 0.3 : Convergence realized after 376  iterations."
## [1] "alpha= 0.1 : Convergence realized after 1039  iterations."
## [1] "alpha= 0.03 : Convergence realized after 3105  iterations."
## [1] "alpha= 0.01 : Convergence realized after 8312  iterations."
```

```r
    # Plot the convergence graph for different values of alpha
    
      plot(1:nrow(Cost_by_iter[[1]]), Cost_by_iter[[1]], type="l",lwd=2,xlab='Number of iterations',ylab='Cost',col=COL[1],
           main=expression(paste("Convergence of gradient descent for a given learning rate ",alpha)),xlim = c(0,min(max(nb_iter),400)))
      
    for(i in 2:length(ALPHA)){
      lines(1:nrow(Cost_by_iter[[i]]), Cost_by_iter[[i]], type="l",lwd=2,col=COL[i])
      }
    

  legend("topright", 
         legend =sapply(ALPHA, function(.) as.expression(bquote(alpha==.(.)))), 
         lwd = 2, cex = 1.2, col = COL, lty = rep(1,4))
```

![](index_files/figure-html/GD_and_plots-1.png)<!-- -->



If we choose $\alpha=0.01$, then we have:


\[\theta=\begin{pmatrix} 34.9604612\\-0.0177253 \\-3.3507588 \end{pmatrix}\]

## Plotting the regression plane

```r
#static plot
static_plot(60)
```

![](index_files/figure-html/static_plot-1.png)<!-- -->




```r
##animated plot
anime_plot()
```


```r
knitr::include_graphics("myReg3Dplots.gif")
```

![](myReg3Dplots.gif)<!-- -->

## Predictions
* **Predict number of Miles/(US) gallon (mpg) for a Displacement of 300.0 cu.in. and a Weight of 4500 lbs** ($4.500\times 1000 lbs$):

```r
mpg_for_300_4.5 = c(c(1, 300,4.5)%*%theta)
```

$\qquad\quad$For a Displacement = 300 cu.in  and a Weight=4500 lbs, we predict **14.56** miles/(US) gallon (mpg).

\
&nbsp;

* **Predict number of Miles/(US) gallon (mpg) for a Displacement of 130.0 cu.in. and a Weight of 2650 lbs** ($2.650\times 1000 lbs$):

```r
mpg_for_130_2.65 = c(c(1, 130,2.65)%*%theta)
```

$\qquad\quad$For a Displacement = 130 cu.in  and a Weight=2650 lbs, we predict **23.78** miles/(US) gallon (mpg).

# Multiple Linear Regression using lm() function of R (Normal equation)

\[\theta=(X^TX)^{-1}X^Ty.\]


```r
model_lm<-lm(mpg~disp + wt,data =mtcars)

model_lm
```

```
## 
## Call:
## lm(formula = mpg ~ disp + wt, data = mtcars)
## 
## Coefficients:
## (Intercept)         disp           wt  
##    34.96055     -0.01772     -3.35083
```

We can see that the values of the fitted parameters are $\hat{\theta_0}=34.96055, \quad\hat{\theta_1}=-0.01772$, and  $\hat{\theta_2}=-3.35083$.

## Summary of the model

```r
summary(model_lm)
```

```
## 
## Call:
## lm(formula = mpg ~ disp + wt, data = mtcars)
## 
## Residuals:
##     Min      1Q  Median      3Q     Max 
## -3.4087 -2.3243 -0.7683  1.7721  6.3484 
## 
## Coefficients:
##             Estimate Std. Error t value Pr(>|t|)    
## (Intercept) 34.96055    2.16454  16.151 4.91e-16 ***
## disp        -0.01773    0.00919  -1.929  0.06362 .  
## wt          -3.35082    1.16413  -2.878  0.00743 ** 
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 2.917 on 29 degrees of freedom
## Multiple R-squared:  0.7809,	Adjusted R-squared:  0.7658 
## F-statistic: 51.69 on 2 and 29 DF,  p-value: 2.744e-10
```




## Predictions
* **Predict number of Miles/(US) gallon (mpg) for a Displacement of 300.0 cu.in. and a Weight of 4500 lbs** ($4.500\times 1000 lbs$):

```r
mpg_for_300_4.5_ =predict.lm(model_lm,data.frame(disp=300,wt=4.5))
```

$\qquad\quad$For a Displacement = 300 cu.in  and a Weight=4500 lbs, we predict **14.56** miles/(US) gallon (mpg).

\
&nbsp;

* **Predict number of Miles/(US) gallon (mpg) for a Displacement of 130.0 cu.in. and a Weight of 2650 lbs** ($2.650\times 1000 lbs$):

```r
mpg_for_130_2.65_ = predict.lm(model_lm,data.frame(disp=130,wt=2.65))
```

$\qquad\quad$For a Displacement = 130 cu.in  and a Weight=2650 lbs, we predict **23.78** miles/(US) gallon (mpg).
