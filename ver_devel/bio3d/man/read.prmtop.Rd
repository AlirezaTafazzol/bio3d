\name{read.prmtop}
\alias{read.prmtop}
\alias{print.prmtop}
\title{ Read AMBER Parameter/Topology files }
\description{
  Read parameter and topology data from an AMBER PrmTop file.
}
\usage{
read.prmtop(file)

\method{print}{prmtop}(x, printseq=TRUE, \dots)
}
\arguments{
  \item{file}{ a single element character vector containing the name of
    the PRMTOP file to be read. }
  \item{x}{ a PRMTOP structure object obtained from
    \code{\link{read.prmtop}}. }
  \item{printseq}{ logical, if TRUE the residue sequence will be printed
    to the screen. See also \code{\link{pdbseq}}. }
  \item{...}{ additional arguments to \sQuote{print}. }
}
\details{
  This function provides basic functionality to read and parse a AMBER
  PrmTop file. The resulting \sQuote{prmtop} object contains a complete
  list object of the information stored in the PrmTop file.

  See examples for further details.
}
\value{
  Returns a list of class \sQuote{prmtop} (inherits class
  \sQuote{amber}) with components according to the flags present in the PrmTop
  file. See the AMBER documentation for a complete list of
  flags/components: \url{http://ambermd.org/formats.html}.

  Selected components:
  \item{ATOM_NAME}{ a character vector of atom names. }
  \item{ATOMS_PER_MOLECULE}{ a numeric vector containing the number of
    atoms per molecule. }
  \item{MASS}{ a numeric vector of atomic masses. }
  \item{RESIDUE_LABEL}{ a character vector of residue labels. }
  \item{RESIDUE_RESIDUE_POINTER}{ a numeric vector of pointers to the
    first atom in each residue. }
  \item{call }{ the matched call. }
}
\references{
  Grant, B.J. et al. (2006) \emph{Bioinformatics} \bold{22}, 2695--2696.
  \url{http://ambermd.org/formats.html}
}
\author{ Lars Skjaerven }
\note{
  See AMBER documentation for PrmTop format description:\cr
  \url{http://ambermd.org/formats.html}.
}
\seealso{
  \code{\link{read.crd}}, \code{\link{read.ncdf}},
  \code{\link{as.pdb}}, \code{\link{atom.select}},
  \code{\link{read.pdb}}
}
\examples{
\dontrun{
## Read a PRMTOP file
prmtop <- read.prmtop(system.file("examples/crambin.prmtop", package="bio3d"))
print(prmtop)

## Explore prmtop file
head(prmtop$MASS)
head(prmtop$ATOM_NAME)

## Read Amber coordinates
crds <- read.crd(system.file("examples/crambin.inpcrd", package="bio3d"))

## Atom selection
ca.inds <- atom.select(prmtop, "calpha")

## Convert to PDB format
pdb <- as.pdb(prmtop, crds)
pdb.ca <- as.pdb(prmtop, crds, inds=ca.inds)

## Trajectory processing
#trj <- read.ncdf("traj.nc", at.sel=ca.inds)

## Convert to multimodel PDB format
#pdb <- as.pdb(prmtop, trj[1:20,], inds=ca.inds, inds.crd=NULL)

## RMSD of trajectory
#rd <- rmsd(crds$xyz[ca.inds$xyz], traj, fit=TRUE)
}
}
\keyword{ IO }
