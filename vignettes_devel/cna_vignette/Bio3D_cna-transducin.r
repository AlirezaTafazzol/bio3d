#' # Supporting Material S4
#' # Integrated structural and evolutionary ensemble analysis with Bio3D
#' **Lars Skj\ae rven, Xin-Qiu Yao & Barry J. Grant**

#+ setup, include=FALSE
opts_chunk$set(dev='pdf')

#+ preamble, include=FALSE, eval=FALSE
library(knitr)
spin('Bio3D_cna-transducin.r')
system("pandoc -o Bio3D_cna-transducin.pdf Bio3D_cna-transducin.md")

#' ## Background:
#' Bio3D[^1] is an R package that provides interactive tools for structural bioinformatics. The primary focus of Bio3D is the analysis of bimolecular structure, sequence and simulation data.

#'
#' Correlation network analysis can be employed to identify protein segments with correlated motions.
#' In this approach, a weighted graph is constructed where each residue represents a node and the 
#' weight of the connection between nodes, *i* and *j*, represents their respective cross-correlation 
#' value, cij, expressed by either the Pearson-like form or the linear mutual information. In this 
#' example, Normal mode analysis (NMA) is employed for the calculation of cross-correlations[^2].

#'
#' [^1]: The latest version of the package, full documentation and further vignettes (including detailed installation instructions) can be obtained from the main Bio3D website: [http://thegrantlab.org/bio3d/](http://thegrantlab.org/bio3d/)
#'
#' [^2]: This document contains executable code that generates all figures contained within this document. See help(vignette) within R for full details. 

#'
#' #### Requirements:
#' Detailed instructions for obtaining and installing the Bio3D package on various platforms can be found in the [**Installing Bio3D Vignette**](http://thegrantlab.org/bio3d/tutorials) available both on-line and from within the Bio3D package. Note that this vignette makes use of the [IGRAPH](http://igraph.org/) R package. 


#'
#' ## Part I: Correlaton network analysis based on single-structure NMA
#' In this example we perform *NMA* on two crystallographic structures of transducin G protein alpha subunits, the active
#' GTP-analog-bound structure (PDB id *1tnd*) and the inactive GDP- and 
#' GDI (GDP dissociation inhibitor)-bound structure (PDB id *1kjy*), by calling the function **nma()**.
#' Cross-correlation matrices are calculated with the function **dccm()**. Correlation networks are
#' then constructed with the function **cna()**. Plotting of networks for comparison is performed
#' with the function **plot.cna()**. See also `help(cna)` for more details.

#+ start, results="hide"
library(bio3d)

#'
#' First, load the previously prepared data for G-alpha, including pre-aligned PDB
#' coordinates (`pdbs`), positions for cores (`core`) and annotations for PDB structures (`annotation`).
#' From the `pdbs` object, two `pdb` objects are extracted, corresponding to *GTP* and *GDI* bound states, respectively.
#+ prep_data, warning=FALSE, results="hide",
attach(transducin)

ids = c("1TND_A", "1KJY_A")
tpdbs = pdbs2pdb(pdbs, match(ids, pdbs$id), rm.gaps=TRUE)
pdb.gtp = tpdbs[[1]]
pdb.gdi = tpdbs[[2]]

#'
#' NMA is then applied to the two PDB structures to obrain state-specific modes of motions. 
#' Following that, residue cross-correlations are calculated based on the normal modes.
#+ nma_cij, cache=TRUE, results="hide", warning=FALSE, 
modes.gtp = nma(pdb.gtp)
modes.gdi = nma(pdb.gdi)
cij.gtp = dccm(modes.gtp)
cij.gdi = dccm(modes.gdi)

#'
#' Correlation networks for both conformational states are constructed by applying
#' function **cna()** to the correspoding correlation matrices. Here, the C-alpha atoms
#' represents nodes which are interconnected by edges with weights corresponding to the pairwise correlation coefficient. 
#' Edges are only constructed for pairs of nodes which obtain a coupling strength larger than a specified cutoff value
#' (0.35 in this example). The weight of each edge is calculated as -log(|cij|), where cij is the 
#' correlation value between two nodes *i* and *j*. For each correlation network, hierarchical clustering 
#' is performed to generate aggregate nodal clusters, or communities, that are highly 
#' intra-connected, but loosely inter-connected. By default, **cna()** returns communities 
#' associated with the maximal modularity value. 

#+ cna
net.gtp = cna(cij.gtp, cutoff.cij=0.35)
net.gtp
net.gdi = cna(cij.gdi, cutoff.cij=0.35)
net.gdi

#+ new-fun 
mod.select <- function(x, thres=0.005) {
   remodel <- community.tree(x, rescale = TRUE)
   n.max = length(unique(x$communities$membership))
   ind.max = which(remodel$num.of.comms == n.max)
   v = remodel$modularity[length(remodel$modularity):ind.max]
   v = rev(diff(v))
   fa = which(v>=thres)[1] - 1
   ncomm = ifelse(is.na(fa), min(remodel$num.of.comms), n.max - fa)

   ind <- which(remodel$num.of.comms == ncomm)
   network.amendment(x, remodel$tree[ind, ])
}

#' Maximization of modularity sometimes creates unexpected community partitions splitting 
#' natural structure motifs, such as secondary structure elements, into many small community islands. To avoid this situation, we look into partitions with modularity close to the maximal value 
#' but the number of communities is smaller. 
 
#+ modularity_selection, cache=TRUE
nnet.gtp = mod.select(net.gtp)
nnet.gtp
nnet.gdi = mod.select(net.gdi)
nnet.gdi

#' Networks can be visulized with Bio3D functions **plot.cna()**, which can generate 2D representations
#' for both full residue-level and coarse-grained community-level networks.

#+ layout
cent.gtp.full = layout.cna(nnet.gtp, pdb=pdb.gtp, full=TRUE, k=3)[,1:2]
cent.gtp = layout.cna(nnet.gtp, pdb=pdb.gtp, k=3)[,1:2]
cent.gdi.full = layout.cna(nnet.gdi, pdb=pdb.gdi, full=TRUE, k=3)[,1:2]
cent.gdi = layout.cna(nnet.gdi, pdb=pdb.gdi, k=3)[,1:2]

#+ figure1, fig.cap="Comparison of correlation networks between active and inhibitory G protein alpha subunits. Networks are derived from NMA applied to single PDB structures."
layout(matrix(c(1:4), 2, 2))
par(mar=c(0.1, 0.1, 3, 0.1))
plot.cna(nnet.gtp, layout=cent.gtp.full, full=TRUE, vertex.label=NA, vertex.size=5)
title(main="GTP")
plot.cna(nnet.gtp, layout=cent.gtp)
plot.cna(nnet.gdi, layout=cent.gdi.full, full=TRUE, vertex.label=NA, vertex.size=5)
title(main="GDI")
plot.cna(nnet.gdi, layout=cent.gdi)

#'
#' ## Part II: Correlation network analysis based on ensemble NMA
#' In this example we perform NMA on the 53 crystallographic transducin G-alpha structures, which can be 
#' categorized into active GTP-analog-bound, inactive GDP-bound, and inhibitory GDI-bound types.
#' Cross-correlation matrices for all structures in the ensemble are calculated with function **dccm()**. 
#' State-specific ensemble average correlation matrices are then obtained with the funciton **cij.filter()**.
#' Correlation networks are finally constructed with the function **cna()**, and visualization of the networks
#' is performed with the function **plot.cna()**:

#+ source-filter, warning=FALSE, 
source("~/workspace/bio3d/new_funs/cij.filter.R")

#+ nma.pdbs, cache=TRUE, warning=FALSE, results="hide",
modes <- nma(pdbs, ncore=8)

#+ dccms, cache=TRUE
cijs0 <- dccm(modes)$all.dccm

#+ cij_filter, cache=TRUE
cijs <- tapply(1:length(pdbs$id), annotation[, "state3"], function(i)
     cij.filter(cijs0, inds=i, xyz=pdbs, model="full",
        cutoff.cij=0.35, cutoff.dm=10, cutoff.pcon=0.75) )
cij <- lapply(cijs, rowMeans, dims=2)

#+ nets, cache=TRUE
nets <- cna(cij, cutoff.cij = 0)
net1 = mod.select(nets$GTP)
net2 = mod.select(nets$GDI)

#+ layout2
cent.gtp.full = layout.cna(net1, pdb=pdb.gtp, full=TRUE, k=3)[,1:2]
cent.gtp = layout.cna(net1, pdb=pdb.gtp, k=3)[,1:2]
cent.gdi.full = layout.cna(net2, pdb=pdb.gdi, full=TRUE, k=3)[,1:2]
cent.gdi = layout.cna(net2, pdb=pdb.gdi, k=3)[,1:2]

#+ figure2, fig.cap="Comparison of correlation networks between active and inhibitory G protein alpha subunit. Networks are derived from NMA based on structure ensemble."
layout(matrix(c(1:4), 2, 2))
par(mar=c(0.1, 0.1, 3, 0.1))
plot.cna(net1, layout=cent.gtp.full, full=TRUE, vertex.label=NA, vertex.size=5)
title(main="GTP")
plot.cna(net1, layout=cent.gtp)
plot.cna(net2, layout=cent.gdi.full, full=TRUE, vertex.label=NA, vertex.size=5)
title(main="GDI")
plot.cna(net2, layout=cent.gdi)


#' ## Document Details
#' This document is shipped with the Bio3D package in both R and PDF formats. All code can be extracted and automatically executed to generate Figures and/or the PDF with the following commands:

#+ close, include=TRUE, eval=FALSE
library(knitr)
spin('Bio3D_cna-transducin.r')
system("pandoc -o Bio3D_cna-transducin.pdf Bio3D_cna-transducin.md")

#'
#' ## Information About the Current Bio3D Session
#'
print(sessionInfo(), FALSE)

