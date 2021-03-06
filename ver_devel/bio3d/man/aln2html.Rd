\name{aln2html}
\alias{aln2html}
\title{ Create a HTML Page For a Given Alignment }
\description{
  Renders a sequence alignment as coloured HTML suitable for viewing
  with a web browser.
}
\usage{
aln2html(aln, file="alignment.html", Entropy=0.5, append=TRUE,
         caption.css="color: gray; font-size: 9pt",
         caption="Produced by <a href=http://thegrantlab.org/bio3d/>Bio3D</a>",
         fontsize="11pt", bgcolor=TRUE, colorscheme="clustal")
}
\arguments{
  \item{aln}{  an alignment list object with \code{id} and \code{ali}
    components, similar to that generated by \code{\link{read.fasta}}. }
  \item{file}{  name of output html file.  }
  \item{Entropy}{ conservation \sQuote{cuttoff} value below which
    alignment columns are not coloured. }
  \item{append}{ logical, if TRUE output will be appended to
    \code{file}; otherwise, it will overwrite the contents of
    \code{file}. }
  \item{caption.css}{ a character string of css options for rendering
    \sQuote{caption} text. }
  \item{caption}{ a character string of text to act as a caption. }
  \item{fontsize}{ the font size for alignment characters. }
  \item{bgcolor}{ background colour. }
  \item{colorscheme}{ conservation colouring scheme, currently only
    \dQuote{clustal} is supported with alternative arguments resulting
    in an entropy shaded alignment.}
}
\value{
  Called for its effect.
}
\references{
  Grant, B.J. et al. (2006) \emph{Bioinformatics} \bold{22}, 2695--2696.
 }
\author{ Barry Grant }
\note{
  Your web browser should support style sheets.
}
\seealso{ \code{\link{read.fasta}}, \code{\link{write.fasta}}, \code{\link{seqaln}} }
\examples{
\dontrun{
## Read an example alignment
aln <- read.fasta(system.file("examples/hivp_xray.fa",package="bio3d"))

## Produce a HTML file for this alignment
aln2html(aln, append=FALSE, file=file.path("eg.html"))
aln2html(aln, colorscheme="ent", file="eg.html")
## View/open the file in your web browser
#browseURL("eg.html")
}
}
\keyword{ IO }
