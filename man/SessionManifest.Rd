% Generated by roxygen2 (4.1.0): do not edit by hand
% Please edit documentation in R/AllClasses.R
\name{SessionManifest}
\alias{SessionManifest}
\alias{SessionManifest-class}
\title{SessionManifest}
\usage{
SessionManifest(manifest, versions)
}
\arguments{
\item{manifest}{A PkgManifest}

\item{versions}{A data.frame with 2 columns: name and version.}
}
\value{
A SessionManifest object
}
\description{
A manifest which includes both a PkgManifest containing package source
information, and a data.frame defining a filter with exact versions
of some or all packages
}

