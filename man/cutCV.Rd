\name{cutCV}
\alias{cutCV}
\title{Calculate cutoff based in CV.}
\description{
	Takes a Codelink object and calculate cutoff based in CV.
}
\usage{
	cutCV(object, subset=c(1:dim(object)[2]))
}
\arguments{
	\item{object}{an object of class "Codelink".}
	\item{subset}{subset of arrays to calculate cutoff with}
}
\value{
}
\details{
    First it computes the median of CV for each gene over all arrays. Then
  it computes the mean and sd of all medians. Finally:

    cutoff = mean + 3 * sd

}
\note{
}
\author{Diego D�ez Ruiz}
\seealso{
}
\examples{
    ## NOT RUN ##
    # data: Normalized Codelink object merged.
    # cutoff <- cutCV(data)
}
\keyword{documentation}
\keyword{utilities}