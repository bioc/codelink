# codCorrect-method.
setGeneric("codCorrect", function(x, method = "half")
	standardGeneric("codCorrect"))
setMethod("codCorrect", "CodelinkSet",
function(x, method = "half")
{
	if(getInfo(x, "background") != "NONE") {
		warning("data already corrected, skipped.")
		return(x)
	}
	
	method <- match.arg(method, c("none"< "subtract", "half", "normexp"))

	# take data.
	int <- assayDataElement(x, "intensity")
	bkgd <- assayDataElement(x, "background")

	# do correction stuff...
	switch(method,
		none = newInt <- int,
		subtract = newInt <- int - bkgd,
		half = newInt <- pmax(int - bkgd, 0.5),
		normexp = newInt <- bgcorrect.normexp(int, bkgd)
	)

	# reassign data.
	#assayDataElement(x, "background") <- NULL
	assayDataElement(x, "intensity") <- newInt
	
	# info.
	experimentData(x)@preprocessing[["background"]] <- method
	
	x
})

# getInfo-method.
setGeneric("getInfo", function(x, what)
	standardGeneric("getInfo"))
setMethod("getInfo", "CodelinkSet",
function(x, what)
{
	if(missing(what))
		experimentData(x)@preprocessing
	else
		experimentData(x)@preprocessing[[what]]
})

# codNormalize-method.
setGeneric("codNormalize", function(x, method = "quantile", log.it = TRUE)
	standardGeneric("codNormalize"))
setMethod("codNormalize", "CodelinkSet",
function(x, method = "quantile", log.it = TRUE)
{
	method <- match.arg(method, c("median", "quantile", "loess"))

	if(getInfo(x, "normalization") != "NONE") {
		warning("data already normalized, skipped.")
		return(x)
	}
	
	# take data.
	newInt <- assayDataElement(x, "intensity")

	# log.it?
	if(log.it && !getInfo(x, "log"))
		newInt <- log2(newInt)
	else
		if(log.it && getInfo(x, "log"))
			warning("already log2 data, skipping...")

	# do normalization stuff.
	switch(method,
		median = newInt <- normalize.median(newInt),
		#quantile = newInt <- normalizeQuantiles(newInt),
		quantile = newInt <- normalize.quantiles(newInt),
		loess = newInt <- normalize.loess(newInt, log.it = FALSE,
			verbose = FALSE)
	)

	# reassign data.
	assayDataElement(x, "intensity") <- newInt
	
	# info.
	experimentData(x)@preprocessing[["normalization"]] <- method
	experimentData(x)@preprocessing[["log"]] <- log.it

	x
})

# codPreprocess-method.
setGeneric("codPreprocess", function(x, bg.method = "half", 
	norm.method = "quantile", log.it = TRUE) standardGeneric("codPreprocess"))
setMethod("codPreprocess", "CodelinkSet",
function(x, bg.method = "half", norm.method = "quantile", log.it = TRUE)
{
	x <- codCorrect(x, method = bg.method)
	x <- codNormalize(x, method = norm.method, log.it = log.it)
	x
})

# exprs method.
setMethod("exprs", "CodelinkSet",
function(object)
{
	getInt(object)
})

# getInt method.
setGeneric("getInt", function(object) standardGeneric("getInt"))
setMethod("getInt", "CodelinkSet",
function(object)
{
	assayDataElement(object, "intensity")
})

# getBkg method.
setGeneric("getBkg", function(object) standardGeneric("getBkg"))
setMethod("getBkg", "CodelinkSet",
function(object)
{
	assayDataElement(object, "background")
})

# getSNR method.
setGeneric("getSNR", function(object) standardGeneric("getSNR"))
setMethod("getSNR", "CodelinkSet",
function(object)
{
	assayDataElement(object, "snr")
})

# getFlag method.
setGeneric("getFlag", function(object) standardGeneric("getFlag"))
setMethod("getFlag", "CodelinkSet",
function(object)
{
	assayDataElement(object, "flag")
})

# probeNames-method.
setGeneric("probeNames", function(object) standardGeneric("probeNames"))
setMethod("probeNames", "CodelinkSet",
function(object)
{
	as.character(pData(featureData(object))[, "probeName"])
})

# probeTypes method to get feature types.
setGeneric("probeTypes", function(object) standardGeneric("probeTypes"))
setMethod("probeTypes", "CodelinkSet",
function(object)
{
	as.character(pData(featureData(object))[, "probeType"])
})

# meanSNR method to get mean SNR values.
setGeneric("meanSNR", function(object) standardGeneric("meanSNR"))
setMethod("meanSNR", "CodelinkSet",
function(object)
{
	pData(featureData(object))[, "meanSNR"]
})

# logicalRow method to get chip row positions.
setGeneric("logicalRow", function(object) standardGeneric("logicalRow"))
setMethod("logicalRow", "CodelinkSet",
function(object)
{
	pData(featureData(object))[, "logicalRow"]
})

# logicalCol method to get chip col positions.
setGeneric("logicalCol", function(object) standardGeneric("logicalCol"))
setMethod("logicalCol", "CodelinkSet",
function(object)
{
	pData(featureData(object))[, "logicalCol"]
})

# experimental codPlot-method.
# this intends to be a general interface for all plotting utilities.
setGeneric("codPlot", function(x, array, what = "ma", ...)
	standardGeneric("codPlot"))

# codPlot, Codelink-method.
# WARNING: WILL BE DEPRECATED.
setMethod("codPlot", "Codelink",
function(x, array, what = "ma", ...)
{
	warning("Use of Codelink objects with the CodelinkSet interface is slow and will be deprecated in the next release.")
	x <- Codelink2eSet(x)
	codPlot(x, array = array, what = what, ...)
})

# codPlot, CodelinkSet-method.
setMethod("codPlot", "CodelinkSet",
function(x, array, what = "ma", ...)
{
	what <- match.arg(what, c("ma", "density", "scatter", "image"))

	switch(what,
		ma = { if(missing(array)) array = 1; codPlotMA(x, array, ...) },
		density = {
			#if(missing(array)) array = NULL
			#codPlotDensity(x, array, ...) },
			codPlotDensity(x, ...) },
		scatter = {
			if(missing(array)) array = 1;
			codPlotScatter(x, array, ...) },
		image = { if(missing(array)) array = 1; codPlotImage(x, array, ...) }
	)
})
# codPlot(), MArrayLM-method.
setMethod("codPlot", "MArrayLM",
function(x, array, what = "ma", ...)
{
	if(missing(array)) array = 1
	codPlotMA(x, array = array, ...)
})

# codPlotMA, generic.
setGeneric("codPlotMA", function(x, array = 1, ...)
	standardGeneric("codPlotMA"))
# codPlotMA, CodelinkSet-method.
setMethod("codPlotMA", "CodelinkSet",
function(x, array = 1, array2, label = "type", cutoff = c(-1, 1),
	snr.cutoff = 1,	legend.x, pch = ".", ...)
{
	label <- match.arg(label, c("type", "snr", "none"))
	type <- probeTypes(x)
	snr <- meanSNR(x)

	# compute MA values.
	X <- getInt(x)
	islog <- getInfo(x, "log")

	X1 <- X[, array]
	if(missing(array2)) {
		# compute mean in non-log scale and restore it if needed.
		X2 <- rowMeans(if(!islog) X else 2**X, na.rm = TRUE)
		if(islog) X2 <- log2(X2)
	} else
		X2 <- X[, array2]

	if(!islog) {
		X1 <- log2(X1)
		X2 <- log2(X2)
	}
	
	M <- X2 - X1
	A <- (X1 + X2) / 2

	samples <- sampleNames(x)
	if(missing(array2)) {
		title <- paste("Median vs", samples[array])
	} else {
		title <- paste(samples[array2], "vs", samples[array])
	}

	plotma(A, M, label = label,	cutoff = cutoff, snr.cutoff = snr.cutoff,
		legend.x = legend.x, pch = pch, type = type, snr = snr, title = title, 
		...)
})
# codPlotMA, MArrayLM-method.
setMethod("codPlotMA", "MArrayLM",
function(x, array = 1, label = "type", cutoff = c(-1, 1),
	snr.cutoff = 1, legend.x, pch = ".", Amean, type, snr, ...)
{
	label <- match.arg(label, c("type", "snr", "none"))
	
	if(missing(type) && label == "type") {
		label = "none"
		warning("missing type information.")
	}   
	if(missing(snr) && label == "snr") {
		label = "none" 
		warning("missing snr info.")
	}

	M <- x$coef[, array]
	if(is.null(x$Amean))
		if(missing(Amean)) stop("no Amean information.")
		else A <- Amean
	else
		A <- x$Amean
	
	title <- colnames(x$coef)[array]
	
	plotma(A, M, label = label,	cutoff = cutoff, snr.cutoff = snr.cutoff,
		legend.x = legend.x, pch = pch, type = type, snr = snr, title = title, 
		...)
})

# codPlotDensity-method.
setGeneric("codPlotDensity", function(x, array, ...)
	standardGeneric("codPlotDensity"))
setMethod("codPlotDensity", "CodelinkSet",
function(x, array, lwd, ...)
{
	X <- getInt(x)
	islog <- getInfo(x, "log")

	if(missing(array))
		array <- 1:dim(X)[2]
	
	if(!islog) X <- log2(X)

	narray <- length(array)
	col <- rainbow(narray)

	d <- list()
	xlim <- c()
	ylim <- c()
	for(n in 1:narray) {
		d[[n]] <- density(X[, n], na.rm = TRUE)
		xlim <- c(xlim, d[[n]]$x)
		ylim <- c(ylim, d[[n]]$y)
	}

	xlim <- range(xlim, na.rm = TRUE)
	ylim <- range(ylim, na.rm = TRUE)

	plot(0, col = "white", xlim = xlim, ylim = ylim, xlab = "Intensity",
		ylab = "Density")
	
	if(missing(lwd)) lwd <- 2

	for(n in 1:narray)
		lines(d[[n]], col = col[n], lwd = lwd, ...)
	
	legend("topright", legend = sampleNames(x), fill = col, bty = "n")
	
	invisible(d)
})
# codPlotImage-method.
setGeneric("codPlotImage", function(x, array = 1, ...)
	standardGeneric("codPlotImage"))
setMethod("codPlotImage", "CodelinkSet",
function(x, array = 1, signal = "bg", low = "white", high = "blue",
	log.it = FALSE, ...)
{
	signal <- match.arg(signal, c("bg", "intensity", "snr"))
	switch(signal,
		bg = X <- getBkg(x)[, array],
		intensity = X <- getInt(x)[, array],
		snr = X <- getSNR(x)[, array]
	)

	if(log.it) X <- log2(X)
	
	d <- getChipDimensions(x)
	if(is.null(d)) {
		gc <- 1
		gr <- 1
	} else {
		gc <- d["gc"]
		gr <- d["gr"]
	}

	rows <- logicalRow(x)
	cols <- logicalCol(x)

	or <- max(rows)
	oc <- max(cols)
	o <- matrix(NA, nrow = or, ncol = oc)
	for(n in 1:length(rows)) {
		o[rows[n], cols[n]] <- X[n]
	}

	col <- colorRampPalette(c(low, high))(123)
	op <- par(mar = c(1, 1, 1, 1))
	on.exit(par(op))

	if(is.null(d)) {
		sc <- oc/gc
		sr <- or/gr
	} else {
		sc <- d["sc"]
		sr <- d["sr"]
	}

	image(0:(gr * sr), 0:(gc * sc), o, col = col, xaxt = "n", yaxt = "n", ...)

	for (igrid in 0:gc) lines(c(0, gr * sr), rep(igrid * sc, 2), lwd = 2)
	for (igrid in 0:gr) lines(rep(igrid * sr, 2), c(0, gc * sc), lwd = 2)
	box(lwd = 2)

	mtext(paste("Array:", array, "Signal: ", signal, " Sample:",
		sampleNames(x)[array]), side=1, cex=0.8)
})
#
setGeneric("getChipDimensions", function(x)
	standardGeneric("getChipDimensions"))
setMethod("getChipDimensions", "character",
function(x)
{
	#if(missing(x)) return(NULL)
	switch(x,
		hwgcod = {
			gc <- 1
			gr <- 12
			sc <- 112
			sr <- 42
		},
		mwgcod = {
			gc <- 1
			gr <- 10
			sc <- 112
			sr <- 41
		},
		rwgcod = {
			gc <- 1
			gr <- 8
			sc <- 112
			sr <- 41
		},
		h20kcod = {
			gc <- 1
			gr <- 1
			sc <- 71
			sr <- 332
		},
		return(NULL)
	)
	return(c(gc = gc, gr = gr, sc = sc, sr = sr))
})
#
setMethod("getChipDimensions", "CodelinkSet",
function(x)
{
	getChipDimensions(x@annotation)
})
#
setGeneric("chipDevice", function(x, f = 3) standardGeneric("chipDevice"))
setMethod("chipDevice", "CodelinkSet",
function(x, f = 3)
{
	arrayNew(f = f, chip = x@annotation)
})