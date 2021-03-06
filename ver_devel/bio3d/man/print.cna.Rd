\name{print.cna}
\alias{print.cna}
\alias{summary.cna}
\title{ Summarize and Print Features of a cna Network Graph }
\description{
  These functions attempt to summarize and print a cna network graph to
  the terminal in a human readable form.
}
\usage{
  \method{print}{cna}(x, ...)
  \method{summary}{cna}(object, verbose=TRUE, ...)
}
\arguments{
  \item{x}{ A cna network and community object as obtained from the
    function \sQuote{cna}.}
  \item{object}{ A cna network and community object as obtained from the
    function \sQuote{cna}.}
  \item{verbose}{ Logical, if TRUE a community summary table is prited 
    to screen.} 
  \item{\dots}{ Extra arguments passed to the \sQuote{write.table}
    function. }
}
\details{
  Simple summary and print methods for protein dynamic networks.
}
\value{
  The function summary.cna returns a list with the following components:
  \item{id}{ A community number/identifier vector with an element for
    each community. }
  \item{size}{ A numeric community size vector, with elements giving
    the number of nodes within each community. }
  \item{members}{ A lst detailing the nodes within each community. }
}
\references{
  Grant, B.J. et al. (2006) \emph{Bioinformatics} \bold{22}, 2695--2696.
}
\author{
    Guido Scarabelli and Barry Grant
}
\seealso{
  \code{\link{cna}}, \code{\link[igraph:print.igraph]{print.igraph}},
  \code{\link[igraph:str.igraph]{str.igraph}}, 
  \code{\link[igraph:igraph.plotting]{igraph.plotting}}
}
\examples{

if (!requireNamespace("igraph", quietly = TRUE)) {
   message('Need igraph installed to run this example')
} else {

## Load the correlation network
attach(hivp)

## Read the starting PDB file to determine atom correspondence
pdbfile <- system.file("examples/hivp.pdb", package="bio3d")
pdb <- read.pdb(pdbfile)

## Examine network composition
print(net)
x<- summary(net)
x$members[[2]]

detach(hivp)

}
}
\keyword{ utilities }

