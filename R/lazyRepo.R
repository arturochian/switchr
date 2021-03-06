
basepkgs = installed.packages(priority="base")[, "Package"]


##' @rdname lazyRepo
##' @aliases lazyRepo,SessionManifest,ANY
setMethod("lazyRepo", c(pkgs = "SessionManifest", pkg_manifest = "ANY"),
          function(pkgs,
                   pkg_manifest,
                   versions,
                   dir = tempdir(),
                   rep_path = file.path(dir, "repo"),
                   get_suggests = FALSE,
                   verbose = FALSE,
                   scm_auths = list(bioconductor = c("readonly", "readonly")),
                   param = SwitchrParam()){

              
              lazyRepo(pkgs = versions_df(pkgs)$name,
                       pkg_manifest = manifest(pkgs),
                       versions = versions_df(pkgs)$version,
                       dir = dir,
                       rep_path = rep_path,
                       get_suggests = get_suggests,
                       verbose = verbose,
                       scm_auths = scm_auths,
                       param = param)
          })

##' @rdname lazyRepo
##' @aliases lazyRepo,character,SessionManifest

setMethod("lazyRepo", c(pkgs = "character", pkg_manifest = "SessionManifest"),
          function(pkgs,
                   pkg_manifest,
                   versions,
                   dir = tempdir(),
                   rep_path = file.path(dir, "repo"),
                   get_suggests = FALSE,
                   verbose = FALSE,
                   scm_auths = list(bioconductor = c("readonly", "readonly"))){

              vers = versions_df(pkg_manifest)$version
              inds = match(pkgs, versions_df(pkg_manifest)$name)
              inds = inds[!is.na(inds)]
              vers = rep(NA, times = length(pkgs))
              vers[inds] = versions_df(pkg_manifest)$version[inds]
              lazyRepo(pkgs = pkgs,
                       pkg_manifest = manifest(pkg_manifest),
                       versions = versions,
                       dir = dir,
                       rep_path = rep_path,
                       get_suggests = get_suggests,
                       verbose = verbose,
                       scm_auths = scm_auths,
                       param = param)
          })


##' @rdname lazyRepo
##' @aliases lazyRepo,character,PkgManifest

setMethod("lazyRepo", c(pkgs = "character", pkg_manifest = "PkgManifest"),
          function(pkgs,
                   pkg_manifest,
                   versions = rep(NA, times = length(pkgs)),
                   dir = tempdir(),
                   rep_path = file.path(dir, "repo"),
                   get_suggests = FALSE,
                   verbose = FALSE,
                   scm_auths = list(bioconductor = c("readonly", "readonly")),
                   param = SwitchrParam()){

              pkgsNeeded = pkgs

              mandf = manifest_df(pkg_manifest)
              avail = available.packages(contrib.url(dep_repos(pkg_manifest)))

              repdir = file.path(rep_path, "src", "contrib")
              dir.create(repdir, recursive = TRUE)
              fakerepo = paste0("file://", normalizePath(repdir))
              innerFun = function(src, pkgname, version, dir) {
                  ## if we only select 1 row we get a character :(
                  if(is.null(dim((avail))))
                      avail = t(as.matrix(avail))

                  if(pkgname %in% avail[,"Package"] || pkgname %in% basepkgs) {
                      if(verbose)
                          message(paste("Package", pkgname, "already available from",
                                        "repository at",
                                        avail[avail[,"Package"] == pkg, "Repository"]))
                      pkgsNeeded <<- setdiff(pkgsNeeded, pkgname)
                      return()
                  }
                  
                  tball = file.path(dir, paste(pkgname, "_", version,
                      ".tar.gz", sep=""))

                  tmpdir = tempdir()
                  pkgdir = file.path(dir, pkgname)               
                  if(file.exists(tball)) {
                      if(verbose)
                          message(sprintf("Package %s (Version %s) already retrieved.",
                                          pkgname, version))
                      
                      pkgsNeeded <<- setdiff(pkgsNeeded, pkgname)
                      desc = untar(tball, files = file.path(pkgname,"DESCRIPTION"),
                          exdir = tmpdir)
                      dcf = read.dcf(file.path(tmpdir, pkgname, "DESCRIPTION")) 
                  } else if(!is.na(version)) {
       
                      pkgfile = locatePkgVersion( src@name, version, pkg_manifest = pkg_manifest,
                          dir = dir)
                      if(is.null(pkgfile))
                          stop("Unable to locate the specified version  of package",
                               src@name)
                      if(file.info(pkgfile)$isdir)
                          desc = file.path(pkgfile, "DESCRIPTION")
                      else {
                          
                          succ= untar(pkgfile, files = file.path(pkgname,"DESCRIPTION"),
                              exdir = tempdir())
                          if(!succ)
                              desc = file.path(tmpdir, pkgname, "DESCRIPTION")
                          else
                              stop("problem extracting DESCRIPTION from tarred package")
                      }
                      dcf = read.dcf(desc)
                  }  else {                         
                      
                      if(verbose)
                          message(sprintf("Retrieving package %s from %s (branch %s)",
                                          pkgname, location(src), branch(branch)))
                      
                      success = makePkgDir(pkgname, src, path = dir,
                          latest_only = is.na(version), param = param)
                      if(!success)
                          stop("Unable to make package directory")

                      dcf = read.dcf(file.path(pkgdir, "DESCRIPTION"))
                  }
                  
                  fields = colnames(dcf)
                  .dcfField = function(field, default = NA) {
                      if(field %in% colnames(dcf)) unname(dcf[1, field]) else NA
                  }
                  row = c(Package = pkgname,
                      Version = .dcfField("Version"),
                      Priority = NA,
                      Depends = .dcfField("Depends"),
                      Imports = .dcfField("Imports"),
                      LinkingTo = .dcfField("LinkingTo"),
                      Suggests = .dcfField("Suggests"),
                      Enhances = NA,
                      License = .dcfField("License"),
                      License_is_FOSS = NA,
                      License_restricts_use = NA,
                      OS_type = .dcfField("OS_type"),
                      Archs = NA,
                      MD5sum = .dcfField("MD5sum"),
                      NeedsCompilation = .dcfField("NeedsCompilation"),
                      File = NA,
                      Repository = fakerepo)
                  
                  rawdeps = c(row["Depends"],
                      row["Imports"],
                      row["LinkingTo"],
                      if(get_suggests) row["Suggests"] else NULL)
                  rawdeps = rawdeps[!is.na(rawdeps)]
                  newreqs = unlist(sapply(rawdeps,
                      tools:::.extract_dependency_package_names))
                  newreqs = unique(newreqs[!newreqs %in% c(avail[,"Package"],
                      pkgsNeeded, basepkgs)])
                  
                  cmd = paste("cd", repdir, "; R CMD build",
                      "--no-resave-data",
                      "--no-build-vignettes", pkgdir)
                  res = tryCatch(system_w_init(cmd, intern=TRUE, param = param),
                      error = function(x) x)
                  if(is(res, "error"))
                      stop(paste("Unable to build package", res))
                  
                  ##update
                  pkgsNeeded <<- setdiff(c(pkgsNeeded, newreqs), pkgname)
                  
                  avail <<- rbind(avail, t(as.matrix(row)))
                  ##   matrix(row, nrow = 1, dimnames = list(pkgname, names(row))))
              }
              force(avail)
              avail = avail[!avail[,"Package"] %in% mandf$name,]
              cnt =1 
              while(length(pkgsNeeded) && cnt < 1000){
                  pkg = pkgsNeeded[1]
                  vers = versions[pkgs == pkg]
                  if(!length(vers))
                      vers = NA
                      
                  if(pkg %in% mandf$name) {
                      manrow = mandf[mandf$name == pkg, ]
                      ##https://github.com/gmbecker/ProteinVis/archive/IndelsOverlay.zip
                      ## for IndelsOverlay branch
                      src = makeSource(name = pkg,
                          type = manrow$type,
                          url = manrow$url, branch = manrow$branch,
                          subdir = manrow$subdir,
                          scm_auth = scm_auths)
                      innerFun(src, pkg, version = vers, dir = repdir) #without versions for now
                  } else if(pkg %in% avail[,"Package"])
                      pkgsNeeded <<- setdiff(pkgsNeeded, pkg)
                  else
                      stop(sprintf("Unable to locate package %s", pkg))
                                        #    }
                  cnt = cnt + 1
              }
              write_PACKAGES(repdir)
              fakerepo
          })

