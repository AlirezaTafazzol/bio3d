list(
  index = list( 
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
        "aln2html",
        "get.pdb",
        "get.seq",
        "load.enmff",
        "write.pdb", 
        "write.crd",
        "write.fasta",
        "write.ncdf",
        "write.pqr",
        "mktrj.nma",
        "mktrj.pca",        
        "view.dccm",
        "view.nma"
      )
    ),

    ##"sequence"
    sd_section("Sequence Analysis:",
               "Do Interesting Things with Protein Sequence",
      c(    
        "consensus",
        "conserv",
        "blast.pdb",
        "entropy",
        "ide.filter",
        "seqidentity",
        "motif.find",
        "pdbaln",
        "seq2aln",
        "seqaln",
        "seqaln.pair",
        "seqbind"

        )   
    ),

    ##"structure"
    sd_section("Structure Analysis:",
               "Do Interesting Things with Protein Structure",
      c(    
        "angle.xyz",
        "blast.pdb",
        "atom.select",
        "combine.sel",
        "cmap",
        "core.find",
        "com",
        "dccm",
        "dccm.mean",
        "dist.xyz",
        "dm",
        "dm.xyz",
        "dssp",
        "fit.xyz",
        "binding.site",
        "mktrj",
        "mktrj.pca",
        "overlap",
        "project.pca",
        "pca.tor",
        "pca.xyz",
        "xyz2z.pca",
        "z2xyz.pca",
        "pdbaln",
        "pdb.annotate",
        "pdb2aln",
        "pdb2aln.ind",
        "pdbfit",
        "chain.pdb",
        "convert.pdb",
        "summary.pdb",
        "rgyr",
        "rmsd",
        "rmsd.filter",
        "rmsf",
        "rmsip",
        "rot.lsq",
        "stride",
        "struct.aln",
        "torsion.pdb",
        "torsion.xyz",
        "wrap.tor",
        "aa2mass",
        "atom.index",
        "atom2mass",
        "dccm.enma",
        "dccm.mean",
        "dccm.nma",
        "dccm.xyz",
        "deformation.nma",
        "fluct.nma",
        "inner.prod",
        "load.enmff",
        "mktrj.nma",
        "nma", 
        "nma.pdbs",
        "normalize.vector",
        "pdbs2pdb",
        "plot.enma",
        "plot.nma",
        "plot.rmsip",
        "sdENM",
        "sse.bridges",
        "view.dccm",
        "view.modes"
        )
    ),


    ##"trajectory"
    sd_section("Trajectory Analysis:",
               "Do Interesting Things with Simulation Data",
      c(    
        "angle.xyz",
        "cmap",
        "core.find",
        "dccm",
        "dccm.mean",
        "dist.xyz",
        "dm",
        "dm.xyz",
        "dssp.trj",
        "fit.xyz",
        "mktrj",
        "mktrj.pca",
        "overlap",
        "project.pca",
        "pca.tor",
        "pca.xyz",
        "xyz2z.pca",
        "z2xyz.pca",
        "pdbaln",
        "rgyr",
        "rmsd",
        "rmsd.filter",
        "rmsf",
        "rmsip",
        "rot.lsq",
        "stride",
        "torsion.pdb",
        "torsion.xyz",
        "wrap.tor"
        )
    ),

    ##"nma"
    sd_section("Normal Mode Analysis:",
               "Probe Large-Scale Protein Motions",
      c(    
        "aa2mass",
        "atom.index",
        "atom2mass",
        "dccm.enma",
        "dccm.mean",
        "dccm.nma",
        "dccm.xyz",
        "deformation.nma",
        "fluct.nma",
        "inner.prod",
        "load.enmff",
        "mktrj",
        "mktrj.nma",
        "nma", 
        "nma.pdbs",
        "normalize.vector",
        "pdbs2pdb",
        "plot.enma",
        "plot.nma",
        "plot.rmsip",
        "sdENM",
        "sse.bridges",
        "view.dccm",
        "view.modes"
        )   
    ),

    ##"graphics"
     sd_section("Graphics:",
               "Plotting and Graphic Display",
      c(
        "bwr.colors",
        "mono.colors",
        "vmd.colors",
        "plot.bio3d",
        "plot.blast",
        "plot.core",
        "plot.dccm",
        "plot.dmat",
        "plot.pca",
        "plot.pca.loadings",
        "plot.pca.score",
        "plot.pca.scree"
        )
    ),

    ##"util"
    sd_section("Utilities:",
               "Convert and Manipulate Data",
      c(
        "aa.index",
        "aa123",
        "aa2index",
        "aa321",
        "aln2html",
        "atom.select",
        "combine.sel",
        "atom2xyz",
        "bio3d-package",
        "bounds",
        "chain.pdb",
        "convert.pdb",
        "diag.ind",
        "difference.vector",
        "gap.inspect",
        "ide.filter",
        "is.gap",
        "is.pdb",
        "is.select",
        "lbio3d",
        "orient.pdb",
        "pairwise",
        "pdb.summary",
        "plot.bio3d",
        "print.core",
        "print.pdb",
        "print.rle2",
        "rle2",
        "rmsd.filter",
        "pdbseq",
        "seqbind",
        "pdbsplit",
        "store.atom",
        "trim.pdb",
        "unbound",
        "vec2resno"
        )
    ),

    ##"example"
    sd_section("Example Data:",
               "Bio3d Example Data",
      c("example.data")
    )#,
    #sd_icon("Some title:",
    #        "some sub-text",
    #        c("pants")
    #        )
  )
)

