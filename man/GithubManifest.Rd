% Generated by roxygen2 (4.1.0): do not edit by hand
% Please edit documentation in R/manifest.R
\name{GithubManifest}
\alias{GithubManifest}
\title{GithubManifest}
\usage{
GithubManifest(..., pkgrepos = as.character(list(...)))
}
\arguments{
\item{pkgrepos}{Github repositories in the form "<user>/<reponame>"}

\item{\dots}{Combined to populate \code{pkgrepos}}
}
\description{
Create a package manifest containing only github packages
}
\note{
This is a convenience wrapper for \code{\link{makeManifest}}. Non-default
location information (e.g. branches other than master,
subdirectories within the repository) are not currently supported. Use
\code{\link{makeManifest}} or edit the package manifest after
creation when those are required.
}

