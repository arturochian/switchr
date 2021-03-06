##' makePkgDir
##' This is an internal function not intended to be called directly by end users
##'
##' Create a directory and populate it with package source code from the
##' specified source
##' @param name The package
##' @param source A PkgSource
##' @param path The path to place the directory
##' @param latest_only Should a fastpath for downloading the latest commit
##' in a SCM package without a formal checkout be used?
##' @param param A SwitchrParam
##' @param forceRefresh Should an existing instance of the package source be
##' deleted/refreshed
##' @docType methods
##' @rdname makePkgDir
##' @export
setGeneric("makePkgDir",
           function(name,
                    source,
                    path,
                    latest_only,
                    param = SwitchrParam(),
                    forceRefresh = FALSE) standardGeneric("makePkgDir"))

##' lazyRepo
##'
##' Create a lazy repository for installing directly from a package
##' manifest. Most users will want to call \code{Install} directly,
##' which will call this as needed behind the scenes.
##'
##' @param pkgs The packages to install
##' @param pkg_manifest The manifest to use
##' @param versions Specific versions of the packages to install. Should be a
##' vector of the same length as \code{pkgs} (and in the same order). Defaults
##' to NA (any version) for all packages.
##' @param dir The directory packages should be downloaded/checkedout/built into
##' @param rep_path The path of the final repository
##' @param get_suggests Whether suggested packages should be included
##' in the lazy repository. Defaults to FALSE
##' @param verbose Should extra information be printed to the user during
##' the construction process
##' @param scm_auths Named list of username/password credentials for checking
##' out package sources from one or more sources listed in \code{manifest}
##' Defaults to readonly access to Bioconductor SVN
##' @param param A SwitchrParam object
##' @return A path to the populated lazy repository, suitable for 'coercing' to
##' a url and installing from.
##' @export
##' @author Gabriel Becker
##' @rdname lazyRepo
##' @docType methods
setGeneric("lazyRepo",
           function(pkgs,
                    pkg_manifest,
                    versions = rep(NA, times = length(pkgs)),
                    dir = tempdir(),
                    rep_path = file.path(dir, "repo"),
                    get_suggests = FALSE,
                    verbose = FALSE,
                    scm_auths = list(bioconductor = c("readonly", "readonly")),
                    param = SwitchrParam()) standardGeneric("lazyRepo"))



##' gotoVersCommit
##' This is a low-level function not intended for direct use by the end user.
##' @docType methods
##' @param dir Directory
##' @param src A PkgSource (or subclass) object
##' @param version The exact version to locate
##' @param param A SwitchrParam
##' @rdname gotoVersCommit
##' @export
setGeneric("gotoVersCommit", function(dir, src, version, param = SwitchrParam()) standardGeneric("gotoVersCommit"))
