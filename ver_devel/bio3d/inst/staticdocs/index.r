##"io"
sd_section("Input/Output:",
           "Read and Write Common Biomolecular Data Types",
  c(
    "read.pdb",
    "read.fasta",
    "read.fasta.pdb",
    "read.ncdf",        
    "read.dcd",
    "read.crd",
    "read.pqr", 
    "read.mol2",     
    "read.all",
    "read.pdcBD",
    "read.cif",
    "read.crd.amber",
    "read.crd.charmm",
    "read.prmtop",
    "aln2html",
    "get.pdb",
    "get.seq",
    "load.enmff",
    "write.pdb", 
    "write.crd",
    "write.fasta",
    "write.ncdf",
    "write.pqr",
    "write.pir",
    "write.mol2",
    "mktrj.nma",
    "mktrj.pca",    
    "mktrj.enma",    
    "pymol",
    "vmd"
  )
)

##"sequence"
sd_section("Sequence Analysis:",
           "Do Interesting Things with Protein Sequence",
  c(    
    "consensus",
    "conserv",
    "blast.pdb",
    "hmmer",
    "pfam",
    "uniprot",
    "entropy",
    "filter.identity",
    "seqidentity",
    "motif.find",
    "pdbaln",
    "seq2aln",
    "seqaln",
    "seqaln.pair",
    "seqbind"
    )   
)

##"structure"
sd_section("Structure Analysis:",
           "Do Interesting Things with Protein Structure",
  c(    
    "angle.xyz",
    "biounit",
    "blast.pdb",
    "get.blast",
    "atom.select",
    "combine.select",
    "cmap",
    "filter.cmap",
    "core.find",
    "com",
    "dccm",
    "filter.dccm",
    "dist.xyz",
    "dm",
    "dssp",
    "dssp.pdbs",
    "geostas",
    "mustang",
    "fit.xyz",
    "binding.site",
    "mktrj",
    "mktrj.pca",
    "overlap",
    "pca",
    "pca.xyz",
    "pca.pdbs",
    "pca.array", 
    "pca.tor",
    "dccm.pca",
    "project.pca",
    "pdbaln",
    "pdb.annotate",
    "pdb2aln",
    "pdb2aln.ind",
    "pdb2sse",
    "pdbs2sse",
    "pdbfit",
    "chain.pdb",
    "convert.pdb",
    "rgyr",
    "rmsd",
    "filter.rmsd",
    "rmsf",
    "rmsip",
    "struct.aln",
    "torsion.pdb",
    "torsion.xyz",
    "wrap.tor",
    "aa2mass",
    "aa.table",
    "atom.index",
    "atom2mass",
    "atom2ele",
    "cov.nma",
    "dccm.enma",
    "dccm.nma",
    "dccm.xyz",
    "deformation.nma",
    "fluct.nma",
    "inner.prod",
    "load.enmff",
    "mktrj.nma",
    "nma", 
    "nma.pdb",
    "nma.pdbs",
    "normalize.vector",
    "pdbs2pdb",
    "plot.enma",
    "plot.nma",
    "plot.rmsip",
    "sdENM",
    "sse.bridges",
    "view.dccm",
    "view.modes",
    "var.xyz",
    "inspect.connectivity"
    )
)


##"trajectory"
sd_section("Trajectory Analysis:",
           "Do Interesting Things with Simulation Data",
  c(    
    "angle.xyz",
    "cmap",
    "filter.cmap",
    "core.find",
    "dccm",
    "dccm.pca",
    "filter.dccm",
#    "lmi",
    "dist.xyz",
    "dm",
    "dssp.xyz",
    "geostas",
    "fit.xyz",
    "mktrj",
    "mktrj.pca",
    "overlap",
    "project.pca",
    "pca.tor",
    "pca.xyz",
    "pdbaln",
    "rgyr",
    "rmsd",
    "filter.rmsd",
    "rmsf",
    "rmsip",
    "torsion.pdb",
    "torsion.xyz",
    "wrap.tor"
    )
)

##"nma"
sd_section("Normal Mode Analysis:",
           "Probe Large-Scale Protein Motions",
  c(    
    "aa2mass",
    "aa.table",
    "atom.index",
    "atom2mass",
    "atom2ele",
    "bhattacharyya",
    "cov.nma",
    "covsoverlap",
    "dccm.enma",
    "dccm.nma",
    "dccm.xyz",
    "deformation.nma",
    "geostas",
    "fluct.nma",
    "inner.prod",
    "load.enmff",
    "mktrj",
    "mktrj.nma",
    "mktrj.enma",
    "nma", 
    "nma.pdb",
    "nma.pdbs",
    "aanma",
    "aanma.pdbs",
    "gnm",
    "dccm.gnm",
    "normalize.vector",
    "pdbs2pdb",
    "plot.enma",
    "plot.nma",
    "plot.rmsip",
    "sdENM",
    "sse.bridges",
    "sip",
    "var.xyz",
    "var.pdbs",
    "view.dccm",
    "view.modes"
    )   
)

##"cna"
 sd_section("Correlation Network Analysis:",
            "Network analysis of dynamic coupling", 
  c(
      "cna",
      "cnapath",
#      "cov2dccm",
      "dccm",
#      "lmi",
      "filter.dccm",
      "cmap",
      "community.tree",
      "network.amendment",
      "view.cna",
      "view.dccm",
      "view.cnapath",
      "plot.cna",
      "print.cna",
      "identify.cna",
      "layout.cna",
      "prune.cna",
      "community.aln"
   )
 )

##"graphics"
 sd_section("Graphics:",
           "Plotting and Graphic Display",
  c(
    "bwr.colors",
    "vmd_colors",
    "mono.colors",
    "plot.bio3d",
    "plot.blast",
    "plot.cmap",
    "plot.core",
    "plot.dccm",
    "plot.dmat",
    "plot.fluct",
    "plot.geostas",
    "plot.pca",
    "plot.pca.loadings",
    "hclustplot",
    "plot.cna",
    "plot.fasta",
    "plot.hmmer",
    "plot.matrix.loadings"
    )
)

##"util"
sd_section("Utilities:",
           "Convert and Manipulate Data",
  c(
    "aa.index",
    "aa123",
    "aa2index",
    "aln2html",
    "as.fasta",
    "as.pdb",
    "as.select",
    "as.xyz",
    "atom.select",
    "combine.select",
    "atom2xyz",
    "basename.pdb",
    "bio3d-package",
    "biounit",
    "bounds",
    "bounds.sse",
    "cat.pdb",
    "check.utility",
    "clean.pdb",
    "chain.pdb",
    "convert.pdb",
    "diag.ind",
    "difference.vector",
    "gap.inspect",
    "get.blast",
    "inspect.connectivity",
    "filter.identity",
    "is.gap",
    "is.pdb",
    "is.select",
    "is.xyz",
    "is.pdbs",
    "is.mol2",
    "lbio3d",
    "mask",
    "orient.pdb",
    "pairwise",
    "plot.bio3d",
    "print.core",
    "print.cna",
    "print.fasta",
    "print.xyz",
    "print.cnapath",
    "print.enma",
    "print.geostas",
    "print.mol2",
    "print.nma",
    "print.pca",
    "print.pdb",
    "print.prmtop",
    "print.rle2",
    "print.select",
    "print.sse",
    "rle2",
    "filter.rmsd",
    "pdbseq",
    "seqbind",
    "pdbsplit",
    "store.atom",
    "trim",
    "trim.mol2",
    "trim.pdbs",
    "trim.xyz",
    "unbound",
    "vec2resno",
    "setup.ncore",
    "elements",
    "formula2mass"
    )
)

##"example"
sd_section("Example Data:",
           "Bio3d Example Data",
  c("example.data")
)
#sd_icon("Some title:",
#        "some sub-text",
#        c("pants")
#        )

