##'@export
setGeneric("libManifest", function(lib = currentCompEnv(),
                                   record_versions = TRUE,
                                   known_manifest = Manifest(dep_repos = repos),
                                   repos = defaultRepos(),
                                   ...)
           standardGeneric("libManifest"))

setMethod("libManifest", "missing",
          function(lib,
                   record_versions = TRUE,
                   known_manifest = Manifest(dep_repos = repos),
                   repos = defaultRepos(),
                   ...) {
              lib = currentCompEnv()
              libManifest(lib = lib, record_versions = record_versions,
                          known_manifest = known_manifest,
                          repos = repos, ...)
          })


setMethod("libManifest", "SwitchrCtx",
          function(lib, record_versions, known_manifest, ...) {
              instpkgs = installed.packages(library_paths(lib))[,"Package"]
              instpkginfo = do.call(rbind, lapply(instpkgs,
                  function(x, fields) {
                      dcf =  read.dcf(system.file("DESCRIPTION", package = x),
                          fields = fields)
                      dcf[,fields]
                  },
                  fields = c("Package", "Version", "SourceType",
                      "SourceLocation",
                      "SourceBranch",
                      "SourceSubdir")))
              mani = PkgManifest(name = instpkginfo[,"Package"],
                  type = instpkginfo[,"SourceType"],
                  url = instpkginfo[,"SourceLocation"],
                  branch = instpkginfo[,"SourceBranch"],
                  subdir = instpkginfo[,"SourceSubdir"],
                  dep_repos  = dep_repos(known_manifest))

              mani = .findThem(mani, known_manifest)
              if(record_versions) {
                  pkg_vers = data.frame(name = instpkgs,
                      version = instpkginfo[,"Version"])
                  mani = SessionManifest(manifest = mani,
                      versions = pkg_vers)
              }
              mani
          })

.findThem = function(manifest, known) {
    df = manifest_df(manifest)
    nas = which(is.na(df$url))
    pkgs = df[nas, "name"]
    ##check known manifest
    known_inds = match(pkgs, manifest_df(known)$name)
    if(any(!is.na(known_inds))) {
        inds = which(!is.na(known_inds))
        known_inds = known_inds[!is.na(known_inds)]
        # gross :-/
        df[nas,][inds,] = manifest_df(known)[known_inds,]
        pkgs = pkgs[-inds]
    }
    if(length(pkgs)) {
        rows = lapply(pkgs, .findIt, repos = dep_repos(manifest),
            avl = available.packages(contrib.url(dep_repos(manifest))))
        df[df$name %in% pkgs,] = do.call(rbind,rows)
    }
    manifest_df(manifest) = df
    manifest
}
           
.findIt = function(pkg, repos, avl) {
    if(pkg == "switchr") {
        ret = ManifestRow(name = pkg,
            url = "http://github.com/gmbecker/switchr", type = "github",
            branch = "master")
        return(ret)
    } else
            
        ret = ManifestRow(name = pkg)
    avl = as.data.frame(avl,
        stringsAsFactors = FALSE)
    if(pkg %in% avl$Package) {
        ret$url = avl[pkg,"Repository"]
        ret$type = .detectType(ret$url)
        ret$branch = "trunk"
    }
        
    ret
}

.detectType = function(url) {
    if (grepl("bioconductor", url, ignore.case=TRUE))
        "bioc"
    else if(grepl("cran", url, ignore.case=TRUE))
        "CRAN"
    else
        "repository"
}