% Generated by roxygen2 (4.1.0): do not edit by hand
% Please edit documentation in R/Utilities.R
\name{findPkgDir}
\alias{findPkgDir}
\title{Find a package directory within an SCM checkout}
\usage{
findPkgDir(rootdir, branch, subdir, repo, param)
}
\arguments{
\item{rootdir}{The directory of the checkout}

\item{branch}{The branch to navigate to}

\item{subdir}{The subdirectory to navigate to}

\item{repo}{a GRANRepository object}

\item{param}{a SwitchrParam object}
}
\value{
A path to the Package sources
}
\description{
Find a package directory within an SCM checkout
}

