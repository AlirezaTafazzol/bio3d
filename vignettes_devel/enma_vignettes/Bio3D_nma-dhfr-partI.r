#' # Supporting Information S2
#' # Integrating protein structural dynamics and evolutionary analysis with Bio3D
#' **Lars Skj\ae rven, Xin-Qiu Yao, Guido Scarabelli & Barry J. Grant**

#+ setup, include=FALSE
opts_chunk$set(dev='pdf')

#+ preamble, include=FALSE, eval=FALSE
library(knitr)
spin('Bio3D_nma-dhfr-partI.r')
system("pandoc -o Bio3D_nma-dhfr-partI.pdf Bio3D_nma-dhfr-partI.md")

#' ## Background:
#' Bio3D[^1] is an R package that provides interactive tools for structural bioinformatics. The primary focus of Bio3D is the analysis of bimolecular structure, sequence and simulation data.

#'
#' Normal mode analysis (NMA) is one of the major simulation techniques used to probe large-scale motions in biomolecules. Typical application is for the prediction of functional motions in proteins. Version 2.0 of the Bio3D package now includes extensive NMA facilities (see also the [**NMA Vignette**](http://thegrantlab.org/bio3d/tutorials)). These include a unique collection of multiple elastic network model force-fields, automated ensemble analysis methods, and variance weighted NMA. Here we provide an in-depth demonstration of ensemble NMA with working code that comprise complete executable examples[^2].

#'
#' [^1]: The latest version of the package, full documentation and further vignettes (including detailed installation instructions) can be obtained from the main Bio3D website: [http://thegrantlab.org/bio3d/](http://thegrantlab.org/bio3d/)
#'
#' [^2]: This document contains executable code that generates all figures contained within this document. See help(vignette) within R for full details. 

#'
#' #### Requirements:
#' Detailed instructions for obtaining and installing the Bio3D package on various platforms can be found in the [**Installing Bio3D Vignette**](http://thegrantlab.org/bio3d/tutorials) available both on-line and from within the Bio3D package. In addition to Bio3D the _MUSCLE_ multiple sequence alignment program (available from the [muscle home page](http://www.drive5.com/muscle/) must be installed on your system and in the search path for executables. Please see the installation vignette for further details.


#'
#' ## Part I: Ensemble NMA of *E.coli* DHFR structures
#' In this vignette we perform *ensemble NMA* on the complete
#' collection of *E.coli* Dihydrofolate reductase (DHFR) structures in the protein databank (PDB).
#' Starting from only one PDB identifier (PDB ID 1rx2) we show how to search the PDB for related structures using BLAST, fetch and align
#' the structures, and finally calculate the normal modes of each individual structre in order
#' to probe for potential differences in structural flexibility.

#'
#' ### Search and retrieve DHFR structures
#' Below we perform a blast search of the PDB database to identify related structures 
#' to our query *E.coli* DHFR sequence. In this particular example we use function 
#' **get.seq(PDBID)** to fetch the query sequence as input to **blast.pdb()**. Note that 
#' **get.seq()** would also allow the UniProt identifier. 

#+ example1a, results="hide"
library(bio3d)

#+ example1b, cache=TRUE, warning=FALSE,
aa <- get.seq("1rx2_A")
blast <- blast.pdb(aa)


#'
#' Function **plot.blast()** facilitates the visualization and filtering of the Blast results. It will attempt
#' to set a seed position to the point of largest drop-off in normalized scores (i.e. the biggest jump in  E-values).
#' In this particular case we specify a cutoff of 225 to include only the relevant *E.coli* structures:

#+ fig1-1, fig.cap="Blast results. Visualize and filter blast results through function **plot.blast()**. Here we proceed with 101 of the top scoring hits."
hits <- plot(blast, cutoff=225)

#'
#' The Blast search and subsequent filtering idientified a total of 101 related PDB structures to our query sequence. 
#' The PDB identifiers of this collection are accessible through the `pdb.id` attribute to the `hits` object (`hits$pdb.id`). 
#' Note that adjusting the cutoff argument (to **plot.blast()**) will result in a decrease or
#' increase of hits. 

#' 
#' We can now use function **get.pdb()** and **pdbslit()** to fetch and parse the identified
#' structures. Finally, we use **pdbaln()** to align the PDB structures. 


#+ example1d1, cache=TRUE, warning=FALSE, results='hide'
# fetch PDBs
raw.files <- get.pdb(hits$pdb.id, path = "raw_pdbs", gzip=TRUE)

#+ example1d2, cache=TRUE, warning=FALSE, results='hide'
# split by chain ID
files <- pdbsplit(raw.files, ids = hits$pdb.id, path = "raw_pdbs/split_chain", ncore=4)

#+ example1d3, cache=TRUE, warning=FALSE, results='hide'
# align structures
pdbs.all <- pdbaln(files, fit=TRUE)

#'
#' The *pdbs.all* object now contains *aligned* C-alpha atom data, including Cartesian coordinates,
#' residue numbers, residue types, and B-factors. The sequence alignment is also stored by default
#' to the FASTA format file 'aln.fa' (to view this you can use an alignment viewer such as SEAVIEW,
#' see _Requirements_ section above). In cases where manual edits of the alignment are necessary
#' you can re-read the sequence alignment and coordinate data with:

#+ example1d4, eval=FALSE
aln <- read.fasta('aln.fa')
pdbs.all <- read.fasta.pdb(aln)

#'
#' At this point the *pdbs.all* object contains all identified 101 structures. This might include 
#' structures with missing residues, and/or multiple structurally redundant conformers. For our
#' subsequent NMA missing in-structure residues might bias the calculation, and redundant structures
#' can be useful to omit to reduce the computational load. Below we inspect the connectivity of the
#' PDB structures with a function call to **inspect.connectivity()**, and **pdbs.filter()** to
#' filter out those structures from our *pdbs.all* object. Similarly, we omit structures that are
#' conformationally redundant to reduce the computational load with funtion **rmsd.filter()**:

#+ example1e, cache=TRUE, warning=FALSE, results='hide'
# remove structures with missing residues
conn <- inspect.connectivity(pdbs.all, cut=4.05)
pdbs <- pdbs.filter(pdbs.all, row.inds=which(conn))

# which structures are omitted
which(!conn)

# remove conformational redundant structures
rd <- rmsd.filter(pdbs$xyz, cutoff=0.1, fit=TRUE)
pdbs <- pdbs.filter(pdbs, row.inds=rd$ind)

# remove "humanized" e-coli dhfr
excl <- unlist(lapply(c("3QL0", "4GH8"), grep, pdbs$id))
pdbs <- pdbs.filter(pdbs, row.inds=which(!(1:length(pdbs$id) %in% excl)))

# a list of PDB codes of our final selection
ids <- unlist(strsplit(basename(pdbs$id), split=".pdb"))

#'
#' Use **print()** to see a short summary of the pdbs object:
#+ example1f, warning=FALSE, cache=TRUE
print(pdbs, alignment=FALSE)


#'
#' ### Annotate collected PDB structures 
#' Function **pdb.annotate()** provides a convenient way of annotating the PDB
#' files we have collected. Below we use the function to annotate each structure to its
#' source species. This will come in handy when annotating plots later on:

#+ example1g, warning=FALSE, cache=TRUE, results='hide'
anno <- pdb.annotate(ids)
print(unique(anno$source))


#'
#' ### Principal component analysis
#' A principal component analysis (PCA) can be performed on the structural ensemble
#' (stored in the *pdbs* object) with function **pca.xyz()**. To obtain meaningful results
#' we first superimpose all structures on the *invariant core* (function **core.find()**).

#+ example1h1, warning=FALSE, cache=TRUE, results='hide'
# find invariant core
core <- core.find(pdbs)

# superimpose all structures to core
pdbs$xyz = pdbfit(pdbs, core$c0.5A.xyz)

# identify gaps, and perform PCA
gaps.pos <- gap.inspect(pdbs$xyz)
gaps.res <- gap.inspect(pdbs$ali)
pc.xray <- pca.xyz(pdbs$xyz[,gaps.pos$f.inds])

#+ example1h2, eval=FALSE
# plot PCA
plot(pc.xray)

#'
#' Note that a call to the wrapper function **pca()** would provide identical results as the above code:

#+ example1h3, eval=FALSE
pc.xray <- pca(pdbs, core.find=TRUE)

#'
#' Function **rmsd()** will calculate all pairwise RMSD values of the structural ensemble. 
#' This facilitates clustering analysis based on the pairwise structural deviation:

#+ example1i, warning=FALSE, cache=TRUE, results='hide'
rd <- rmsd(pdbs)
hc.rd <- hclust(dist(rd))
grps.rd <- cutree(hc.rd, k=4)

#'
#' Projection of the X-ray conformers on to their two largest eigenvectors shows that the
#' E.coli DHFR structures can be divided into three major groups: closed, open, and occluded conformations: 

#+ figi-1, fig.cap="Projection of MD conformers onto the X-ray PC space reveals that the E.coli DHFR structures can be divided into three major groups along their two first eigenvectors. Each dot is colored according to their cluster membership: occluded conformations (green), open conformations (black), and closed conformations (red). ", fig.height=5, fig.width=5,
plot(pc.xray$z[,1:2], col="grey50", pch=16, cex=1.3,
     ylab="Prinipcal Component 2", xlab="Principal Component 1")
points(pc.xray$z[,1:2], col=grps.rd, pch=16, cex=0.9)

#'
#' To visualize the major structural variations in the ensemble function **mktrj()** can be used to generate a trajectory
#' PDB file by interpolating along the eigenvector:

#+ example1hi2, eval=FALSE
mktrj(pc.xray, pc=1,
      resno=pdbs$resno[1, gaps.res$f.inds],
      resid=pdbs$resid[1, gaps.res$f.inds])


#'
#' Function **pdbfit()** can be used to write the PDB files to seperate directories according to their cluster membership:

#+ example1j, eval=FALSE
pdbfit(pdbs.filter(pdbs, row.inds=which(grps.rd==1)), outpath="grps1") ## closed
pdbfit(pdbs.filter(pdbs, row.inds=which(grps.rd==2)), outpath="grps2") ## open
pdbfit(pdbs.filter(pdbs, row.inds=which(grps.rd==3)), outpath="grps3") ## occluded


#'
#' ### Normal modes analysis
#' Function **nma.pdbs()** will calculate the normal modes of each protein structure stored
#' in the *pdbs* object. The normal modes are calculated on the full structures as provided
#' by object *pdbs*. With the default argument `rm.gaps=TRUE` unaligned atoms 
#' are omitted from output:

#+ example1k, cache=TRUE, warning=FALSE,
modes <- nma.pdbs(pdbs, rm.gaps=TRUE, ncore=4)

#'
#' The *modes* object of class *enma* contains aligned normal mode data including fluctuations,
#' RMSIP data, and aligned eigenvectors. A short summary of the *modes* object can be obtain by
#' calling the function **print()**, and the aligned fluctuations can be plotted with function
#' **plot.enma()**. This function also facilitates the calculation and visualization of sequence conservation
#' (use argument `conservation=TRUE`), and fluctuation variance (use argument `variance=TRUE`).

#+ example1l, cache=TRUE, warning=FALSE,
print(modes)

#+ fig1l-1, fig.cap="Normal mode fluctuations of the E.coli DHFR ensemble. (**upper panel**) Each line represent the mode fluctuations for the individual structures. Color coding according to structural clustering: green (occluded), black (open), and red (closed). (**lower panel**) Variance of mode fluctuations. The Met20 loop seems to display the largest deviations / differences in predicted fluctuations. ", fig.height=7,
# plot modes fluctuations
plot(modes, pdbs=pdbs, col=grps.rd, variance=TRUE)

#+ example1m, cache=TRUE, warning=FALSE,
hc.nma <- hclust(as.dist(1-modes$rmsip))
grps.nma <- cutree(hc.nma, k=4)

#+ fig1m-1, fig.cap="Clustering of structures based on their normal modes similarity (in terms of pair-wise RMSIP values)."
heatmap(1-modes$rmsip, distfun = as.dist, labRow = ids, labCol = ids,
        ColSideColors=as.character(grps.nma), RowSideColors=as.character(grps.nma))

#'
#' ### Fluctuation analysis
#' Comparing the mode fluctuations of two groups of structures 
#' can reveal specific regions of distinc flexibility patterns. Below we focus on the
#' differences between the open (black), closed (red) and occluded (green) conformations
#' of the *E.coli* structures: 

          
#+ fig1n-1, fig.cap="Comparison of mode fluctuations between open (black) and closed (red) conformers. Significant differences among the mode fluctuations between the two groups are marked with shaded blue regions.", fig.height=4.5,
cols <- grps.rd
cols[which(cols!=1 & cols!=2)]=NA
plot(modes, pdbs=pdbs, col=cols, signif=TRUE)

#+ fig1n-2, fig.cap="Comparison of mode fluctuations between open (black) and occluded (green) conformers. Significant differences among the mode fluctuations between the two groups are marked with shaded blue regions.", fig.height=4.5,
cols <- grps.rd
cols[which(cols!=1 & cols!=3)]=NA
plot(modes, pdbs=pdbs, col=cols, signif=TRUE)

#+ fig1n-3, fig.cap="Comparison of mode fluctuations between closed (red) and occluded (green) conformers. Significant differences among the mode fluctuations between the two groups are marked with shaded blue regions.", fig.height=4.5,
cols <- grps.rd
cols[which(grps.rd!=2 & grps.rd!=3)]=NA
plot(modes, pdbs=pdbs, col=cols, signif=TRUE)


#'
#' ### Compare with MD simulation
#' The above analysis can also nicely be integrated with molecular dynamics (MD) simulations. Below we read in a 5 ns long MD trajectory (of PDB ID 1RX2). We visualize the conformational sampling by projecting the MD conformers onto the principal components (PCs) of the X-ray ensemble, and finally compare the PCs of the MD simulation to the normal modes:

#+ example1o, eval=TRUE, results='hide'
pdb <- read.pdb("md-traj/1rx2-CA.pdb")
trj <- read.ncdf("md-traj/1rx2_5ns.nc")

md.inds <- pdb2aln.ind(aln=pdbs, pdb=pdb, id="md", inds=gaps.res$f.inds)
trj <- trj[, atom2xyz(md.inds)]
trj <- fit.xyz(fixed=pdbs$xyz[1, ],  mobile=trj,
               fixed.inds=core$c0.5A.xyz, mobile.inds=core$c0.5A.xyz)

proj <- pca.project(trj, pc.xray)
cols <- densCols(proj[,1:2])

#+ fig1o-1, fig.cap="Projection of MD conformers onto the X-ray PC space provides a two dimensional representation of the conformational sampling along the MD simulation (blue dots).", fig.height=4.5, fig.width=4.5,
plot(proj[,1:2], col=cols, pch=16,
     ylab="Prinipcal Component 2", xlab="Principal Component 1",
     xlim=range(pc.xray$z[,1]), ylim=range(pc.xray$z[,2]))
points(pc.xray$z[,1:2], col=1, pch=1, cex=1.1)
points(pc.xray$z[,1:2], col=grps.rd, pch=16)

#+ example1p, eval=TRUE
# PCA of the MD trajectory
pc.md <- pca.xyz(trj)

# compare MD-PCA and NMA
r <- rmsip(pc.md$U, modes$U.subspace[,,1])

print(r)

#+ fig1p-1, fig.cap="Overlap map betwen normal modes and principal components of a 5 ns long MD simulation. The two subsets yields an RMSIP value of 0.64, where a value of 1 would idicate identical directionality.", fig.height=4.5, fig.width=4.5,
plot(r, xlab="MD PCA", ylab="NMA")

# compare MD-PCA and X-rayPCA
r <- rmsip(pc.md, pc.xray)


#'
#' ### Domain analysis with GeoStaS
#' Identification of regions in the protein that move as rigid bodies is facilitated
#' with the implementation of the GeoStaS algorithm [^3]. Below we demonstrate the use of function
#' **geostas()** on data obtained from ensemble NMA, an ensemble of PDB structures, and a 5 ns long
#' MD simulation. See `help(geostas)` for more details and further examples.

#'
#' **GeoStaS on a PDB ensemble**: Below we input the `pdbs` object to function
#' **geostas()** to identify dynamic domains. Here, we attempt to divide the structure into
#' 2 sub-domains using argument `k=2`. Function **geostas()** will return a `grps` attribute
#' which corresponds to the domain assignment for each C-alpha atom in the structure.
#' Note that we use argument `fit=FALSE` to avoid re-fitting the coordinates since. Recall that
#' the coordinates of the `pdbs` object has already been superimposed to the identified
#' invariant core (see above). To visualize the domain assignment we write a PDB trajectory
#' of the first principal component (of the Cartesian coordinates of the `pdbs` object),
#' and add argument `chain=gs.xray$grps` to replace the chain identifiers with the domain
#' assignment:


#+ example1_gs-pdbs, cache=TRUE, results="hide",
# Identify dynamic domains
gs.xray <- geostas(pdbs, k=2, fit=FALSE)

# Visualize PCs with colored domains (chain ID)
mktrj(pc.xray, pc=1, chain=gs.xray$grps)

#'
#' **GoeStaS on ensemble NMA**: We can also identify dynamic domains from the normal modes of the ensemble
#' of 82 protein structures stored in the `modes` object. By using function **mktrj.enma()**
#' we generate a trajectory from the first five modes for all 82 structures. We then input this
#' trajectory to function **geostas()**. 

#+ example1_gs-nma, cache=TRUE,
# Build conformational ensemble
trj.nma <- mktrj.enma(modes, pdbs, m.inds=1:5, s.inds=NULL, mag=10, step=2, rock=FALSE)

trj.nma

# Fit to invariant core
trj.nma <- fit.xyz(trj.nma[1,], trj.nma,
                   fixed.inds=core$c0.5A.xyz,
                   mobile.inds=core$c0.5A.xyz)

# Run geostas to find domains
gs.nma <- geostas(trj.nma, k=2, fit=FALSE)

#+ example1_gs-nma2, eval=FALSE,
# Write NMA generated trajectory with domain assignment
write.pdb(xyz=trj.nma, chain=gs.nma$grps)


#'
#' **GeoStaS on a MD trajectory**: The domain analysis can also be performed on the trajectory data obtained
#' from the MD simulation (see above). Recall that the MD trajectory has already been superimposed
#' to the invariant core. We therefore use argument `fit=FALSE` below. We then perform a
#' new PCA of the MD trajectory, and visualize the domain assingments with function **mktrj()**:

#+ example1_gs-md, cache=TRUE, results="hide",
gs.md <- geostas(trj, k=2, fit=FALSE)
pc.md <- pca(trj, fit=FALSE)
mktrj(pc.md, pc=1, chain=gs.md$grps)



#' ![Visualization of domain assignments using function **geostas()** for x-ray ensemble (left), ensemble NMA (middle), and MD trajectory (right).](figure/geostas-domains.png)



#'
#' ### Measures for modes comparison
#' Bio3D now includes multiple measures for the assessment of similarity between two normal mode
#' objects. This enables clustering of related proteins based on the predicted modes of motion.
#' Below we demonstrate the use of root mean squared inner product (RMSIP), squared inner product (SIP), covariance overlap, bhattacharyya coefficient, and PCA of the corresponding covariance matrices. 

#+ example1q-sip, eval=TRUE, results='hide', cache=TRUE
# Similarity of atomic fluctuations
sip <- sip(modes)
hc.sip <- hclust(as.dist(1-sip), method="ward.D2")
grps.sip <- cutree(hc.sip, k=3)

#+ fig1q-sip, fig.cap="Dendrogram shows the results of hierarchical clustering of structures based on the similarity of atomic fluctuations calculated from NMA. Colors of the labels depict associated conformatial state: green (occluded), black (open), and red (closed). The inset shows the conformerplot (see Figure 2), with colors according to clustering based on pairwise SIP values.", 
hclustplot(hc.sip, k=3, colors=grps.rd, labels=ids, cex=0.7, main="SIP")

par(fig=c(.55, 1, .55, 1), new = TRUE)
plot(pc.xray$z[,1:2], col="grey50", pch=16, cex=1.3, 
     ylab="", xlab="", axes=FALSE, bg="red")
points(pc.xray$z[,1:2], col=grps.sip, pch=16, cex=0.9)
box()


#+ example1q-rmsip, eval=TRUE, results='hide', cache=TRUE
# RMSIP
rmsip <- rmsip(modes)
hc.rmsip <- hclust(dist(1-rmsip), method="ward.D2")
grps.rmsip <- cutree(hc.rmsip, k=3)

#+ fig1q-rmsip, fig.cap="Dendrogram shows the results of hierarchical clustering of structures based on their pairwise RMSIP values (calculated from NMA). Colors of the labels depict associated conformatial state: green (occluded), black (open), and red (closed). The inset shows the conformerplot (see Figure 2), with colors according to clustering based on the pairwise RMSIP values.", 
hclustplot(hc.rmsip, k=3, colors=grps.rd, labels=ids, cex=0.7, main="RMSIP")

par(fig=c(.55, 1, .55, 1), new = TRUE)
plot(pc.xray$z[,1:2], col="grey50", pch=16, cex=1.3, 
     ylab="", xlab="", axes=FALSE)
points(pc.xray$z[,1:2], col=grps.rmsip, pch=16, cex=0.9)
box()


#+ example1q-co, eval=TRUE, results='hide', cache=TRUE
# Covariance overlap
co <- covsoverlap(modes, subset=200)
hc.co <- hclust(as.dist(1-co), method="ward.D2")
grps.co <- cutree(hc.co, k=3)

#+ fig1q-co, fig.cap="Dendrogram shows the results of hierarchical clustering of structures based on their pairwise covariance overlap (calculated from NMA). Colors of the labels depict associated conformatial state: green (occluded), black (open), and red (closed). The inset shows the conformerplot (see Figure 2), with colors according to clustering of the Covariance overlap measure.", 
hclustplot(hc.co, k=3, colors=grps.rd, labels=ids, cex=0.7, main="Covariance overlap")

par(fig=c(.55, 1, .55, 1), new = TRUE)
plot(pc.xray$z[,1:2], col="grey50", pch=16, cex=1.3, 
     ylab="", xlab="", axes=FALSE)
points(pc.xray$z[,1:2], col=grps.co, pch=16, cex=0.9)
box()


#+ example1q-bc, eval=TRUE, results='hide', cache=TRUE
# Bhattacharyya coefficient
covs <- enma2covs(modes)
bc <- bhattacharyya(modes, covs=covs)
hc.bc <- hclust(dist(1-bc), method="ward.D2")
grps.bc <- cutree(hc.bc, k=3)

#+ fig1q-bc, fig.cap="Dendrogram shows the results of hierarchical clustering of structures based on their pairwise Bhattacharyya coefficient (calculated from NMA). Colors of the labels depict associated conformatial state: green (occluded), black (open), and red (closed). The inset shows the conformerplot (see Figure 2), with colors according to clustering of the pairwise Bhattacharyya coefficients.", 
hclustplot(hc.bc, k=3, colors=grps.rd, labels=ids, cex=0.7, main="Bhattacharyya coefficient")

par(fig=c(.55, 1, .55, 1), new = TRUE)
plot(pc.xray$z[,1:2], col="grey50", pch=16, cex=1.3, 
     ylab="", xlab="", axes=FALSE)
points(pc.xray$z[,1:2], col=grps.bc, pch=16, cex=0.9)
box()


#+ example1q-pcaco, eval=TRUE, results='hide', cache=TRUE
# PCA of covariance matrices
pc.covs <- pca.array(covs)
hc.covs <- hclust(dist(pc.covs$z[,1:2]), method="ward.D2")
grps.covs <- cutree(hc.covs, k=3)

#+ fig1q-pcaco, fig.cap="Dendrogram shows the results of hierarchical clustering of structures based on the PCA of covariance matrices (calculated from NMA). Colors of the labels depict associated conformatial state: green (occluded), black (open), and red (closed). The inset shows the conformerplot (see Figure 2), with colors according to clustering based on PCA of covariance matrices.", 
hclustplot(hc.covs, k=3, colors=grps.rd, labels=ids, cex=0.7, main="PCA of covariance matrices")

par(fig=c(.55, 1, .55, 1), new = TRUE)
plot(pc.xray$z[,1:2], col="grey50", pch=16, cex=1.3, 
     ylab="", xlab="", axes=FALSE)
points(pc.xray$z[,1:2], col=grps.covs, pch=16, cex=0.9)
box()


#'
#' [^3]: Romanowska, J., Nowinski, KS., Trylska, J., (2012). Determining geometrically stable domains in molecular conformation sets. *J Chem Theory Comput*, 8(8), 2588–99.


#'
#' ## Document Details
#' This document is shipped with the Bio3D package in both R and PDF formats. All code can be extracted and automatically executed to generate Figures and/or the PDF with the following commands:

#+ close, include=TRUE, eval=FALSE
library(knitr)
spin('Bio3D_nma-dhfr-partI.r')
system("pandoc -o Bio3D_nma-dhfr-partI.pdf Bio3D_nma-dhfr-partI.md")

#'
#' ## Information About the Current Bio3D Session
#'
print(sessionInfo(), FALSE)





