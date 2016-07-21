
// -----------------------------------------------------------------------------
// BUGS: 
//		* The matrix and character vectors are not returned correctly...
//		* The string comes with a {break}. limit this to only when it's needed
//		* Character class is messed up in the list
//		* PROBLEM WITH CHARACTER VECTORS
// =============================================================================
R: mylist <- list(a=c(1:10), b=c("hello", "world"), c=matrix(1:6, nrow=2, byrow = TRUE))



// -----------------------------------------------------------------------------
// General Setup
// =============================================================================

// Install the package from GitHub
net install Rcall, force  from("https://raw.githubusercontent.com/haghish/Rcall/master/")

// Setup R path permanently
R setpath "/usr/bin/r"

// -----------------------------------------------------------------------------
// Vanilla (Non-Interactive)
// =============================================================================
R: rm(list=ls()) 
Rcall: unlink(".RData")
Rcall vanilla : object <- print("this")
return list

// if you want to access the "object" you get an error that is not found
Rcall: object


// -----------------------------------------------------------------------------
// From R to Stata (Interactive)
// =============================================================================

R: a <- print("Hello World")
R: q()						//does not remove the R objects in memory
R: print(ls())

R: rm(list=ls()) 			//remove the R objects in memory
R: print(ls())

//numeric and string objects
Rcall: a <- 10
R: b <- " or it can be string"
display "The object value is can be numetic such as " r(a) r(b)

//define a matrix
R: A = matrix(1:6, nrow=2, byrow = TRUE) 
mat list r(A)

// SPECIAL CHARACTERS

R: attach(cars)
R: cars\$speed		  //the $ sign must be 

//Stata interprets $ sign in the middle of a word as global macro, use backslash
R: head(cars\$speed)
R: LM <- lm(cars\$dist~cars\$speed)
R: LM
return list //lm is not a list

// -----------------------------------------------------------------------------
// From Stata to R (Interactive)
// =============================================================================
R: rm(list=ls()) 			//remove the R objects in memory

// NUMERIC and STRING LOCAL & GLOBAL
// ---------------------------------------
local  a = 99
global b = 99
Rcall: c <- `a' + $b
display r(c)

global a "thi is a string"
Rcall: b <- "$a"
display r(b)


// st.matrix() : Passing a NUMERIC matrix from Stata to R
// ----------------------------------------
matrix A = (1,2\3,4) 
Rcall: A <- st.matrix(A) + st.matrix(A) + st.matrix(A) + st.matrix(A)
mat list r(A)

R: rm(list=ls())
matrix A = (1,2\3,4) 
matrix B = (96,96\96,96) 		
R: C <- st.matrix(A) + st.matrix(B)
R: C

// st.scalar() : Passing a NUMERIC & STRING SCALAR to R
// ----------------------------------------
scalar a = 999
Rcall: a <- st.scalar(a)
display r(a)

scalar a = "or string scalar"
Rcall: a <- st.scalar(a)
display r(a)


// st.data() : Passing Data to R
// ----------------------------------------

sysuse auto, clear
R: data <- st.data()
R: dim(data)

clear
R: rm(list=ls())
R: data <- st.data(/Applications/Stata/ado/base/a/auto.dta)


// load.data() : Passing Data from R to Stata 
// ----------------------------------------
clear 
Rcall: mydata <- data.frame(cars) 
Rcall: load.data(mydata) 
list in 1/2


// -----------------------------------------------------------------------------
// Source an R script file and get all of the objects back to Stata
// =============================================================================
R: rm(list=ls())
R: source('https://raw.githubusercontent.com/haghish/Rcall/master/examples/get.R')
mat list r(matrixObject)
display r(mystr)


Rcall: unlink(".RData") //This deletes the workspace file


// -----------------------------------------------------------------------------
// Trying Rcpp package
// =============================================================================

/*
To compile the C++ code, use sourceCpp("path/to/file.cpp"). This will create 
the matching R functions and add them to your current session. Note that these 
functions can not be saved in a .Rdata file and reloaded in a later session; 
they must be recreated each time you restart R. 

But you can add several R commands separated by ";", or more better, create a 
script file and source it all at once. 
*/

cd "/Users/haghish/Documents/Packages/Rcall"
Rcall: library(Rcpp)
Rcall: Rcpp::sourceCpp('examples/Rcpp.cpp'); timesTwo(2);timesTwo(999);

Rcall: Rcpp::sourceCpp('examples/Rcpp.cpp'); a <- timesTwo(10003)

//save the results of Rcpp in an R object, and get it back in Stata!
display r(a)

// -----------------------------------------------------------------------------
// RProfile : Detach packages, data, variables, etc..
// =============================================================================
/*
Anytime you close R in batch mode, it detaches all of the packages you have loaded. 
To make R really run interactively in Stata, the packages should remain loaded 
for each command. Rcall makes a global RProfile that remains active regardless 
of your working directory. 

However, anything that you leave in .RData, means extra loading time for every Rcall. So 
if you don't need a data set, package, etc, remove them from the R Workspace and 
detach the packages. 
*/

R: search()
R: detach("package:Rcpp", unload=TRUE)
R: search()


// -----------------------------------------------------------------------------
// Execution time
// =============================================================================
timer clear
timer on 1
	R:
timer off 1
timer list

/* 
calling R from Stata without executing anything takes 0.41 seconds on average
on my Machine. Repeating the call for 10 times reveals simply the multiplication 
of this number. 

I SHOULD SPEED UP THIS PROCESS
*/

timer clear
timer on 1
	R:
	R:
	R:
	R:
	R:
	R:
	R:
	R:
	R:
	R:
timer off 1
timer list


