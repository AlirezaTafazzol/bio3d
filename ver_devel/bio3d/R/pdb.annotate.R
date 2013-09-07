# function: pdb.annotate
# date: 08/06/2013, edited 08/30/2013
# returns a matrix of requested annotation terms.

pdb.annotate <- function(ids, anno.terms=NULL) {
    oops <- require(XML)
    if(!oops)
        stop("Please install the XML package from CRAN")

    ## All availalbe annotation terms (note 'citation' is a meta term)
    anno.allterms <- c("structureId", "experimentalTechnique", "resolution", "chainId", "ligandId",
                       "ligandName", "source", "scopDomain", "classification", "compound", "title",
                       "citation", "citationAuthor", "journalName", "publicationYear")
    
    if(is.null(anno.terms)) {
      anno.terms <- anno.allterms
    } else {
      ## Check and exclude invalid annotation terms
      term.found <- (anno.terms %in% anno.allterms)
      if( any(!term.found) ) {
        warning( paste("Requested annotation term not availalbe:",
                       paste(anno.terms[!term.found], collapse=", "),
                       "\n  Available terms are:\n\t ",
                       paste(anno.allterms, collapse=", ")) )
      }
      anno.terms <- match.arg(anno.terms, anno.allterms, several.ok=TRUE)
    }

    ## Check if we have any valid terms remaining
    if( length(anno.terms) == 0 ) {
      stop( paste("No valid anno.terms specified. Please select from:\n\t ",
                       paste(anno.allterms, collapse=", ")) )
    }

    if (missing(ids)) 
    {
        stop("please specify PDB ids for annotating")
    }
    if (any(nchar(ids) != 4)) 
    {
        warning("ids should be standard 4 character PDB formart: trying first 4 char...")
        ids <- substr(basename(ids), 1, 4)
    }
    
    ids1 <- paste(unique(ids), collapse=",")

    query1 = paste(anno.allterms[anno.allterms != "citation"], collapse=",")
    ##- Instead of looking up all therms we could specify only those requested here... 
    ##query1 = paste(anno.terms[anno.terms != "citation"], collapse=",")
    ##- if 'citation' is asked for we would then need to make sure we look up year, author and journal
    ##query1 <- unique( c(query1, "citationAuthor", "journalName", "publicationYear" ) )
    
    
    cmd <- paste("http://www.rcsb.org/pdb/rest/customReport?pdbids=",
                 ids1, "&customReportColumns=",
                 query1, "&ssa=n&primaryOnly=1", sep = "")
    
    tmpfile <- tempfile()
    test <- download.file(cmd, tmpfile)

    ## Check status of download.
    if(test!=0) {
      stop("Annotation report could not be downloaded from PDB, Please check returned value")
    }

    ##- Parse the xml file
    doc = xmlRoot(xmlTreeParse(tmpfile))
    tmp1 = xmlApply(doc, function(x) xmlApply(x, xmlValue))
    tmp2 <- tmp1[[1]]
    if(length(tmp1)>=2) {
      for(i in 2:length(tmp1)) {
        tmp2 <- mapply(c, tmp2, tmp1[[i]], SIMPLIFY=FALSE)
      }
      ## list tmp2 to matrix tmp3
      tmp3 <- sapply(tmp2, unlist)
    }
    if(length(tmp1)==1) {
      tmp3 <- t(as.matrix(tmp2))
    }
    
    ## information of unique ids
    pdb.ids <- as.vector(tmp2[[1]])
    dup.len <- rle(pdb.ids)
    unq.ids <- dup.len$values[ (dup.len$lengths==1) ]
    new.tbl <- as.matrix(tmp3[pdb.ids %in% unq.ids,])

    ## if there was only one unique id, we need the transformation of the matrix new.tbl
    if(length(unq.ids)==1)
        new.tbl <- t(new.tbl)

    if(length(which(duplicated(pdb.ids))) >= 1)
    {
        dup.rows <- bounds(which(duplicated(pdb.ids)))
        ## information of duplicated ids
        for( i in 1:nrow(dup.rows))
        {
            l <- tmp3[ (dup.rows[i,"start"]-1):dup.rows[i,"end"], ]
            row.store <- NULL
            for(j in 1:ncol(l))
            {
             row.store <- c(row.store, paste(unique(as.vector(l[,j])), collapse=", "))
            }
        new.tbl <- rbind(new.tbl, row.store)
        }
    }
    ## format the colnames
    colnames(new.tbl) <- colnames(tmp3)

    ## change colnames (e.g. dimEntity.structureId -> structureId)
    for( i in 1:ncol(new.tbl))
    {
    a <- unlist(strsplit(colnames(new.tbl)[i], "\\."))
    colnames(new.tbl)[i] <- a[2]
    }

    ## Format citation information
    if (any(anno.terms == "citation") ) {
      citation <- NULL
      lig.auth <- new.tbl[,"citationAuthor"]
      lig.year <- new.tbl[,"publicationYear"]
      lig.jnal <- new.tbl[,"journalName"]

      for(i in 1:length(lig.auth)) {
        citation <- c(citation, paste( unlist(strsplit(lig.auth[[i]], ","))[1],
                                      " et al. ", lig.jnal[i], " (", lig.year[i],")",sep=""))
      }
      new.tbl <- cbind(new.tbl, citation)
    }

    rownames(new.tbl) <- new.tbl[, "structureId"]
    out.tbl <- as.matrix(new.tbl[, anno.terms])

    ## again, we need the transformation of the matrix out.tbl
    if(length(ids)==1) { out.tbl <- t(out.tbl) }
    
    ## return a matrix of required annotation
    colnames(out.tbl) <- anno.terms
    return(out.tbl)
}