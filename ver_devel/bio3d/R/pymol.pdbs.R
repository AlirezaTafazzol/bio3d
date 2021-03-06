## takes a vector of residue numbers and generates a string
## e.g. (1,2,3,5,8,9) --> "1-3,5,8-9"
.resno2str <- function(res, sep=c("+", "-")) {
  res <- res[!is.na(res)]
  if(!length(res)>0){
    return(NULL)
  }
  else {
    res1 <- bounds(res)
    res2 <- paste(res1[,"start"], res1[,"end"], sep=sep[2])
    inds <- res1[,"start"] == res1[,"end"]
    res2[inds] <- res1[inds, "start"]
    res3 <- paste(res2, collapse=sep[1])
    return(res3)
  }
}

pymol <- function(...)
  UseMethod("pymol")

pymol.pdbs <- function(pdbs, col=NULL, as="ribbon", file=NULL,
                       type="script", exefile = "pymol", ...) {
  
  allowed <- c("session", "script", "launch")
  if(!type %in% allowed) {
    stop(paste("input argument 'type' must be either of:",
               paste(allowed, collapse=", ")))
  }

  allowed <- c("ribbon", "cartoon", "lines", "putty")
  if(!as %in% allowed) {
    stop(paste("input argument 'as' must be either of:",
               paste(allowed, collapse=", ")))
  }

  if(!is.null(col) & !inherits(col, "core")) {
    if(length(col) == 1) {
      allowed <- c("index", "index2", "rmsf", "gaps")
      if(!col %in% allowed) {
        stop(paste("input argument 'col' must be either of:",
                   paste(allowed, collapse=", ")))
      }
    }
    else {
      if(!is.numeric(col)) {
        stop("col must be a numeric vector with length equal to the number of structures in the input pdbs object")
      }
      
      if(length(col) != length(pdbs$id)) {
        stop("col must be a vector with length equal to the number of structures in input pdbs")
      }
    }
  }
  
  ## output file name
  if(is.null(file)) {
    if(type=="session")
      file <- "R.pse"
    if(type=="script")
      file <- "R.pml"
  }
 
    ## Check if the program is executable
    if(type %in% c("session", "launch")) {
        
        ## determine path to exefile
        exefile1 <- .get.exepath(exefile)
        
        ## Check if the program is executable
        success <- .test.exefile(exefile1)
        
        if(!success) {
            stop(paste("Launching external program failed\n",
                       "  make sure '", exefile, "' is in your search path", sep=""))
        }
        exefile <- exefile1
    }
    
  ## use temp-dir unless we output a PML script
  if(type %in% c("session", "launch"))
    tdir <- tempdir()
  else
    tdir <- "."

  pdbdir <- paste(tdir, "pdbs", sep="/")
  if(!file.exists(pdbdir))
    dir.create(pdbdir)
  
  pmlfile <- tempfile(tmpdir=tdir, fileext=".pml")
  psefile <- tempfile(tmpdir=tdir, fileext=".pse")
  ids <- basename.pdb(pdbs$id)

  ## include stuff in the b-factor column
  bf <- NULL
  if(as == "putty") {
    bf <- rmsf(pdbs$xyz)
  }
  else {
    if(!is.null(col)) {
      ## RMSF coloring
      if(col[1] == "rmsf") {
        bf <- rmsf(pdbs$xyz)
      }
      ## color by index of pdbs$ali
      if(col[1] == "index2") {
        bf <- 1:ncol(pdbs$ali)/ncol(pdbs$ali)
      }
    }
  }
  
  ## use all all-atom PDBs if they exist
  if(all(file.exists(pdbs$id))) {
    allatom <- TRUE
    files <- pdbs$id

    ## align all-atom PDBs to pdbs$xyz
    for(i in 1:length(pdbs$id)) {
      pdb <- read.pdb(files[i])
      sele <- atom.select(pdb, "calpha")
      gaps <- is.gap(pdbs$xyz[i,])
      pdb$xyz <- fit.xyz(pdbs$xyz[i, !gaps], pdb$xyz,
                         fixed.inds = 1:length(pdbs$xyz[i, !gaps]),
                         mobile.inds = sele$xyz)
      fn <- paste0(pdbdir, "/", ids[i], ".pdb")

      ## store new b-factor column to PDB
      tmpbf <- NULL
      if(!is.null(bf)) {
        gaps <- is.gap(pdbs$ali[i,])
        tmpbf <- pdb$atom$b*0
        tmpbf[sele$atom] <- bf[!gaps]
      }

      write.pdb(pdb, b=tmpbf, file=fn)
      files[i] <- fn
    }
  }
  else {
    ## use pdbs$xyz to build CA-atom PDBs
    allatom <- FALSE
    files <- rep(NA, length(pdbs$id))
    for(i in 1:length(pdbs$id)) {
      pdb <- pdbs2pdb(pdbs, inds=i)[[1]]
      fn <- paste0(pdbdir, "/", ids[i], ".pdb")

      ## store new b-factor column to PDB
      tmpbf <- NULL
      if(!is.null(bf)) {
        gaps <- is.gap(pdbs$ali[i,])
        tmpbf <- bf[!gaps]
      }
        
      write.pdb(pdb=pdb, b=tmpbf, file=fn)
      files[i] <- fn
    }
  }

  ## load PDBs
  lines <- rep(NA, 5*length(pdbs$id))
  for(i in 1:length(files)) {
    lines[i] <- paste("load", files[i])
  }

  ## line pointer
  l <- i

  
  ## Structure representation (as)
  if(as == "putty") {
    lines[l+1] <- "cartoon putty"
    lines[l+2] <- "as cartoon"
    lines[l+3] <- "unset cartoon_smooth_loops"
    lines[l+4] <- "unset cartoon_flat_sheets"
    lines[l+5] <- "spectrum b, rainbow"
    lines[l+6] <- "set cartoon_putty_radius, 0.2"
    l <- l+6

    as <- "cartoon"
  }
  
  if(!allatom) {
    if(!as %in% c("cartoon", "ribbon")) {
      warning("'as' set to 'ribbon' for c-alpha only structures")
      as <- "ribbon"
    }

    lines[l+1] <- paste0("set ", as, "_trace_atoms, 1")
    l <- l+1
  }
  
  lines[l+1] <- paste("as", as)
  l <- l+1
  ## representation ends
  
  
  ## Coloring
  if(!is.null(col)) {
    if(inherits(col, "core")) {
      core <- col
      l <- l+1
      lines[l] <- "color grey50"
      
      for(j in 1:length(files)) {
        res <- .resno2str(pdbs$resno[j, core$atom])
        if(!is.null(res)) {
          selname <- paste0(ids[j], "-core")
          lines[l+1] <- paste0("select ", selname, ", ", ids[j], " and resi ", res)
          lines[l+2] <- paste0("color red, ", selname)
          l <- l+2
        }
      }
    }
    
    if(col[1] == "gaps") {
      l <- l+1
      lines[l] <- "color grey50"
      
      gaps <- gap.inspect(pdbs$ali)
      for(j in 1:length(files)) {
        res <- .resno2str(pdbs$resno[j, gaps$t.inds])
        if(!is.null(res)) {
          selname <- paste0(ids[j], "-gap")
          lines[l+1] <- paste0("select ", selname, ", ", ids[j], " and resi ", res)
          lines[l+2] <- paste0("color red, ", selname)
          l <- l+2
        }
      }
    }
    
    if(length(col) > 1 & is.vector(col)) {
      
      ## add more colors here
      cols <- c("grey40", "red", "green", "blue", "cyan",
                "purple", "yellow", "grey90", "magenta", "orange",
                "pink", "wheat", "deepolive", "teal", "violet",
                "limon", "slate", "density", "forest", "smudge", "salmon",
                "brown")

      for(j in 1:length(files)) {
        lines[l+1] <- paste0("color ", cols[col[j]], ", ", ids[j])
        l <- l+1
      }
    }

    ## color by RMSF
    if(col[1] == "rmsf") {
      l <- l+1
      lines[l] <- "spectrum b, rainbow"
    }

    ## color by index of individual structures
    if(col[1] == "index") {
      for(i in 1:length(pdbs$id)) {
        l <- l+1
        lines[l] <- paste("spectrum count, rainbow,", ids[i], "and name C*")
      }
    }

    ## color by index of alignment
    if(col[1] == "index2") {
      for(i in 1:length(pdbs$id)) {
        l <- l+1
        lines[l] <- paste("spectrum b, rainbow,", ids[i])
      }
    }
  } ## coloring ends
  

  lines[l+1] <- "zoom"
  l <- l+1
  
    if(type == "session") {
        lines[l+1] <- paste("save", 
                            normalizePath(psefile, winslash='/', mustWork=FALSE))
    }
  
  lines <- lines[!is.na(lines)]
  write.table(lines, file=pmlfile, append=FALSE, quote=FALSE, sep="\n",
              row.names=FALSE, col.names=FALSE)

  if(type %in% c("session", "launch")) {
    if(type == "session")
      args <- "-cq"
    else
      args <- ""
    
    ## Open pymol
    cmd <- paste(exefile, args, pmlfile)

    os1 <- Sys.info()["sysname"]
    if (os1 == "Windows") {
        status <- shell(paste(shQuote(exefile), args, pmlfile))
    }
    else {
        status <- system(cmd)
    }
    
    if(!(status %in% c(0,1))) {
        stop(paste("An error occurred while running command\n '",
                   exefile, "'", sep=""))
    }

  }
    
  if(type == "session") {
      file.copy(psefile, file, overwrite=TRUE)
      unlink(pmlfile)
      unlink(psefile)
      message(paste("PyMOL session written to file", file))
      invisible(file)
  }
    
  if(type == "script") {
      file.copy(pmlfile, file, overwrite=TRUE)
      unlink(pmlfile)
      message(paste("PyMOL script written to file", file))
      invisible(file)
  }
}
