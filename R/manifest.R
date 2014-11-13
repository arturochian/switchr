
                  


emptyManifest = data.frame(name = character(),
    url = character(),
    type = character(),
    branch = character(),
    subdir = character(),

    extra = character(),
    stringsAsFactors = FALSE
    )
    

##'ManifestRow
##'
##' Create one or more rows of manifest
##'
##' @param name name of the package
##' @param url location of the package sources
##' @param type type of location (svn, git, local, etc)
##' @param branch name of the branch to use to build the package
##' @param subdir subdirectory to use to build the package
##' @param extra currently ignored. extra commands for building or
##' installing the package
##' @return A valid Package manifest data.frame
##' @export
ManifestRow = function(name = NA,
    url = NA,
    type = NA,
    branch = NA,
    subdir = ".",
    extra = NA
    ) {

    if(is.na(type) && !is.na(url))
        type = .inferType(url)
    if(is.na(branch) && !is.na(type))
        branch = .inferDefaultBranch(branch, type)
    data.frame(name = name, url = url, type = type,
           branch = branch, subdir = subdir, extra = extra,
           stringsAsFactors = FALSE)
}

##' @export
Manifest = function(..., dep_repos = c(biocinstallRepos())) {
    rows = mapply(ManifestRow, ..., SIMPLIFY=FALSE)
    PkgManifest(manifest = do.call(rbind.data.frame, rows), dep_repos = dep_repos)
}

##XXX can't specify non-defaults in a lot of the columns


##' @export
GithubManifest = function( ..., pkgrepos = as.character(list(...))) {

    names = gsub(".*/(.*)(.git){0,1}$", "\\1", pkgrepos)
    res =Manifest(url = paste0("git://github.com/", pkgrepos, ".git"),
             type = "git", branch = "master", name = names)
    as(res, "GithubPkgManifest")
}



        
gitregex = "^(git:.*|http{0,1}://(www.){0,1}(github|bitbucket)\\.com.*|.*\\.git)$"


.inferType = function(urls) {
    types = character(length(urls))
    gits = grep(gitregex, urls)
    types[gits] = "git"
    types
}

.inferDefaultBranch= function(branch, type) {
    switch(type,
           git = "master",
           svn = "trunk",
           NA)
}
           

##' readManifest 
##'
##' Read a package or session manifest from a remote or local directory
##'
##' @param uri The location of the manifest directory (path or URL)
##' @param local Whether the manifest is a local directory or a URL
##' @param archive Not currently supported
##' @return A PackageManifest object, or a SessionManifest object if the
##' manifest directory contains a pkg_versions.dat file.
##' @importFrom RCurl url.exists
##' @export
readManifest = function(uri, local = !url.exists(uri), archive = FALSE) {
    if(archive)
        stop("support for archived manifest directories is forthcoming")
    if(!local) {
        dir = tempdir()
        download.file(paste(uri, "pkg_locations.dat", sep ="/"),
                      file.path(dir, "pkg_locations.dat"))
        download.file(paste(uri, "dep_repos.txt", sep ="/"),
                      file.path(dir, "dep_repos.txt"))
        if(url.exists(paste(uri, "pkg_versions.dat", sep="/"))) {
            download.file(paste(uri, "dep_repos.dat", sep ="/"),
                          file.path(dir, "pkg_versions.dat"))
        }
    }
    pkgman = read.table(file.path(dir, "pkg_locations.dat"), header = TRUE,
        sep = "\t")
    deprepos = readLines(file.path(dir, "dep_repos.txt"))
    manifest = PkgManifest(manifest = pkgman, dep_repos = deprepos)
    if(file.exists(file.path(dir, "pkg_versions.dat"))) {
        vers = read.table(file.path(dir, "pkg_versions.dat"),
            header = TRUE, sep="\t")
        SessionManifest(pkg_versions = vers,
                        pkg_manifest = manifest)
    } else {
        manifest
    }
}