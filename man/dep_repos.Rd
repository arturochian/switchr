% Generated by roxygen2 (4.1.0): do not edit by hand
% Please edit documentation in R/accessors.R
\docType{methods}
\name{dep_repos}
\alias{dep_repos}
\alias{dep_repos,PkgManifest}
\alias{dep_repos,PkgManifest-method}
\alias{dep_repos,SessionManifest}
\alias{dep_repos,SessionManifest-method}
\alias{dep_repos<-}
\alias{dep_repos<-,PkgManifest}
\alias{dep_repos<-,PkgManifest-method}
\alias{dep_repos<-,SessionManifest}
\alias{dep_repos<-,SessionManifest-method}
\title{dep_repos}
\usage{
dep_repos(x)

\S4method{dep_repos}{PkgManifest}(x)

\S4method{dep_repos}{SessionManifest}(x)

dep_repos(x) <- value

\S4method{dep_repos}{PkgManifest}(x) <- value

\S4method{dep_repos}{SessionManifest}(x) <- value
}
\arguments{
\item{x}{A package or session manifest}

\item{value}{A character vector with the new dependency repos}
}
\value{
Character vector with existing repository urls
}
\description{
Get or set repositories to be used to fullfill dependencies beyond packages
within the manifest


}

