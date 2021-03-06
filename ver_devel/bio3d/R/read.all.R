"read.all" <-
function(aln, prefix="", pdbext="", sel=NULL, rm.wat=TRUE, rm.ligand=FALSE, 
             compact=TRUE, ncore=NULL, ...) {

  ## Usage:
  ## sel <- c("N", "CA", "C", "O", "CB", "*G", "*D",  "*E", "*Z")
  ## pdbs.all <- read.all(aln, sel=sel)

  if(!inherits(aln, 'fasta')) 
      stop( paste("input 'aln' should be a list object as obtained from ", 
                  "'seqaln()', 'pdbaln()', or 'read.fasta.pdb()'") )

  dots <- list(...)
  if(!'verbose' %in% names(dots)) dots$verbose = FALSE

  ## Log the call
  cl <- match.call()

  ncore <- setup.ncore(ncore)
 
  files  <- paste(prefix, aln$id, pdbext,sep="")

  ##cat(files,sep="\n")
  toread <- file.exists(files)

  ## check for online files
  toread[ substr(files,1,4)=="http" ] <- TRUE


  if(all(!toread))
    stop("No corresponding PDB files found")

  ## Avoid multi-thread downloading
  if(any(substr(files,1,4) == "http")) {
     ncore = 1
  }

  if(ncore>1) {
    prev.warn <- getOption("warn")
    options(warn=1)
    on.exit(options(warn=prev.warn))
  }

  ## make default selection
  if(is.null(sel)) sel <- store.atom()

  blank <- rep(NA, ncol(aln$ali))
  blank.all <- rep(NA, ncol(aln$ali)*length(sel))

#  for (i in 1:length(aln$id)) {
  rtn <- mclapply(1:length(aln$id), function(i) {

    cat(paste("pdb/seq:",i,"  name:", aln$id[i]),"\n")

    if(!toread[i]) {
      warning(paste("No PDB file found for seq", aln$id[i],
              ": (with filename) ",files[i]), call.=FALSE)
      coords <- rep(blank,3)
      res.nu <- blank
      res.bf <- blank
      res.ch <- blank
      res.id <- blank
      res.ss <- blank
      res.in <- blank
      ## all atom data
      coords.all <- rep(blank.all, 3)
      elety.all <- blank.all
      resid.all <- blank.all 
      resno.all <- blank.all
      hetatm <- NULL
      ##
      ##coords.all
      ##
    } else {
      pdb <- do.call(read.pdb, c(list(files[i]), dots) )

      ## Always remove hydrogen
      pdb <- atom.select(pdb, 'noh', value=TRUE, verbose=FALSE)

      hetatm <- atom.select(pdb, 'protein', inverse=TRUE, value=TRUE, verbose=FALSE)

      if(rm.wat)
        hetatm <- trim(hetatm, 'water', inverse=TRUE, verbose=FALSE)

      if(rm.ligand)
        hetatm <- trim(hetatm, 'ligand', inverse=TRUE, verbose=FALSE)

      if(nrow(hetatm$atom)==0) hetatm <- NULL

      ## Following works on protein only
      pdb <- atom.select(pdb, 'protein', value=TRUE, verbose=FALSE)

      ca.inds <- atom.select(pdb, "calpha", verbose=FALSE)
      pdbseq  <- pdbseq(pdb)
      aliseq  <- toupper(aln$ali[i,])
      tomatch <- gsub("X","[A-Z]",aliseq[!is.gap(aliseq)])

      if(length(pdbseq)<1)
        stop(paste(basename(aln$id[i]), ": insufficent Calpha's in PDB"), call.=FALSE)
      
      ##-- Search for ali residues (1:15) in pdb
      start.num <- regexpr(pattern = paste(c(na.omit(tomatch[1:15])),collapse=""),
                           text = paste(pdbseq,collapse=""))[1]
      if (start.num == -1) {
        stop("Starting residues of sequence not found in PDB")
      }

      ##-- Numeric vec, 'nseq', for mapping aln to pdb
      nseq <- rep(NA,length(aliseq))
      ali.res.ind <- which(!is.gap(aliseq))
      if( length(ali.res.ind) > (length(pdbseq) - start.num + 1) ) {
        warning(paste(aln$id[i],
         ": sequence has more residues than PDB has Calpha's"), call.=FALSE)
        ali.res.ind <- ali.res.ind[1:(length(pdbseq)-start.num+1)] ## exclude extra
        tomatch <-  tomatch[1:(length(pdbseq)-start.num+1)]        ## terminal residues
      }
      nseq[ali.res.ind] = start.num:((start.num - 1) + length(tomatch))

      ##-- Check for miss-matches
      match <- aliseq != pdbseq[nseq] 
      if ( sum(match, na.rm=TRUE) >= 1 ) {
        mismatch.ind <- which(match)
        mismatch <- cbind(aliseq, pdbseq[nseq])[mismatch.ind,]
        n.miss <- length(mismatch.ind)

        if(sum(mismatch=="X") != n.miss) { ## ignore masked X res        
          details <- rbind(aliseq, !match,
                           pdbseq[nseq],
                           pdb$atom[pdb$calpha,"resno"][nseq] )
                           #### calpha[,"resno"][nseq] ) ###- typo??
          details <- seqbind(aliseq, pdbseq[nseq])
          details$ali[is.na(details$ali)] <- "-"
          rownames(details$ali) <- c("aliseq","pdbseq")
          details$id <- c("aliseq","pdbseq")
          
          resmatch <- which(!apply(details$ali, 2, function(x) x[1]==x[2]))
          
          resid <- paste(pdb$atom$resid[ca.inds$atom][nseq][resmatch][1], "-",
                         pdb$atom$resno[ca.inds$atom][nseq][resmatch][1],
                         " (", pdb$atom$chain[ca.inds$atom][nseq][resmatch][1], ")", sep="")
          
          cat("\n ERROR   Alignment mismatch. See alignment below for further details\n")
          cat("         (row ", i, " of aln and sequence of '", aln$id[i], "').\n", sep="")
          cat("         First mismatch residue in PDB is:", resid, "\n")
          cat("         occurring at alignment position:", which(match)[1], "\n\n")
          .print.fasta.ali(details)
          
          msg <- paste(basename.pdb(aln$id[i]),
                       " alignment and PDB sequence miss-match\n",
                       "       beginning at position ",
                       which(match)[1], " (PDB RESNO ", resid, ")", sep="")
          stop(msg, call.=FALSE)

        }
      }
      
      ##-- Store nseq justified PDB data
      ca.ali <- pdb$atom[pdb$calpha,][nseq,]
      coords <- as.numeric( t(ca.ali[,c("x","y","z")]) )
      res.nu <- ca.ali[, "resno"]
      res.bf <- as.numeric( ca.ali[,"b"] )
      res.ch <- ca.ali[, "chain"]
      res.id <- ca.ali[, "resid"]
      res.in <- ca.ali[, "insert"]
      
      sse <- pdb2sse(pdb, verbose = FALSE)
      if(!is.null(sse)) 
        res.ss <- sse[nseq]
      else
        res.ss <- blank

      raw <- store.atom(pdb)
      coords.all <- as.numeric( raw[c("x","y","z"), sel, nseq] )
      elety.all <- c(raw[c("elety"),sel,nseq])
      resid.all <- c(raw[c("resid"),sel,nseq])
      resno.all <- c(raw[c("resno"),sel,nseq])

##      raw <- store.main(pdb)
##      b <- cbind(b, raw[,,nseq])

    } # end else 
    list(coords=coords, coords.all=coords.all, res.nu=res.nu, res.bf=res.bf,
         res.ch=res.ch, res.id=res.id, res.in=res.in, res.ss=res.ss, elety.all=elety.all, 
         resid.all=resid.all, resno.all=resno.all, hetatm=hetatm)
  }, mc.cores=ncore, mc.allow.recursive=FALSE) # end for

  tryerr <- which(sapply(rtn, inherits, 'try-error'))
  if(length(tryerr)>0) {
    stop(as.character(rtn[[tryerr[1]]]))
  }

  coords <- do.call( rbind, unname(sapply(rtn, '[', 'coords')) )
  res.nu <- do.call( rbind, unname(sapply(rtn, '[', 'res.nu')) )
  res.bf <- do.call( rbind, unname(sapply(rtn, '[', 'res.bf')) )
  res.ch <- do.call( rbind, unname(sapply(rtn, '[', 'res.ch')) )
  res.id <- do.call( rbind, unname(sapply(rtn, '[', 'res.id')) )
  res.ss <- do.call( rbind, unname(sapply(rtn, '[', 'res.ss')) )
  res.in <- do.call( rbind, unname(sapply(rtn, '[', 'res.in')) )
  
  if( all(is.na(res.ss)) ) res.ss <- NULL
  if( all(is.na(res.in)) ) {
    res.in <- NULL
  } else {
    res.in[is.na(res.in)] <- ''
  }
  
  coords.all <- do.call( rbind, unname(sapply(rtn, '[', 'coords.all')) )
  elety.all <- do.call( rbind,  unname(sapply(rtn, '[', 'elety.all')) )
  resid.all <- do.call( rbind,  unname(sapply(rtn, '[', 'resid.all')) )
  resno.all <- do.call( rbind,  unname(sapply(rtn, '[', 'resno.all')) )
  hetatm.all <- unname(sapply(rtn, '[', 'hetatm'))

  if(all(sapply(hetatm.all, is.null))) hetatm.all <- NULL

  rownames(aln$ali) <- aln$id
  rownames(coords) <- aln$id
  rownames(res.nu) <- aln$id
  rownames(res.bf) <- aln$id
  rownames(res.ch) <- aln$id
  rownames(res.id) <- aln$id
  if(!is.null(res.ss)) rownames(res.ss) <- aln$id
  if(!is.null(res.in)) rownames(res.in) <- aln$id
  
  rownames(coords.all) <- aln$id
  rownames(elety.all) <- aln$id
  rownames(resid.all) <- aln$id
  rownames(resno.all) <- aln$id
  if(!is.null(hetatm.all)) names(hetatm.all) <- aln$id

  atm <- rep( rep(sel,each=3), ncol(aln$ali))
  colnames(coords.all) = atm
  atm <- rep( sel, ncol(aln$ali))
  colnames(elety.all) = atm
  colnames(resid.all) = atm
  colnames(resno.all) = atm

  coords <- as.xyz(coords)
  coords.all <- as.xyz(coords.all)

  width <- ncol(elety.all) / ncol(aln$ali)
  grpby <- rep(1:ncol(aln$ali), each=width)
  if(compact) {
    # remove columns that have NA in all rows
    rm.inds <- which(apply(elety.all, 2, function(x) all(is.na(x))))
    if(length(rm.inds) > 0) {
      coords.all <- as.xyz(coords.all[, -atom2xyz(rm.inds)])
      elety.all <- elety.all[, -rm.inds, drop=FALSE]
      resid.all <- resid.all[, -rm.inds, drop=FALSE]
      resno.all <- resno.all[, -rm.inds, drop=FALSE]
      grpby <- grpby[-rm.inds]
    } 
  } 

  out<-list(xyz=coords, all=coords.all, resno=res.nu, insert=res.in, b=res.bf,
            chain = res.ch, id=aln$id, ali=aln$ali, resid=res.id, sse=res.ss,
            all.elety=elety.all, all.resid=resid.all, all.resno=resno.all,
            all.grpby=grpby, all.hetatm=hetatm.all, call = cl)

  class(out)=c("pdbs", "fasta")
  return(out)
  
}

