suppressPackageStartupMessages(library("optparse"))
suppressPackageStartupMessages(library("gifski"))
option_list <- list( 
  make_option(
    "--frames", type = "character", 
    help = "png files given by a glob (e.g. pic*.png)"
  ),
  make_option(
    "--fps", type = "integer", default = 20L,
    help = "frames per second (default 20)"
  ),
  make_option(
    c("-l", "--loop"), type = "integer", default = 0L, 
    help = "number of loops, 0 for infinite (the default)",
    metavar = "number"
  ),
  make_option(
    c("-s", "--size"), type = "character", default = "512x512", 
    help = paste0(
      "size of the gif given in the form WxH where W is the width in pixels ", 
      "and H is the height in pixels (default 512x512)"
    ),
    metavar = "WxH"
  ),
  make_option(
    c("-b", "--backward"), action = "store_true", default = FALSE, 
    help = "loop forward and backward"
  ),
  make_option(
    c("-o", "--output"), type = "character", default = "animation.gif", 
    help = "output gif file (default animation.gif)", 
    metavar = "output.gif"
  )
)
opt <- parse_args(OptionParser(
  option_list = option_list, prog = "gifski"
))

# check options are correct
size_ok <- grepl("^\\d.*x\\d.*$", opt$size)
if(!size_ok)
  stop("Invalid 'size' option.")
if(opt$fps <= 0)
  stop("Invalid 'fps' option.")
if(opt$loop < 0)
  stop("Invalid 'loop' option.")

png_files <- Sys.glob(opt$frames)
if(length(png_files) == 0L)
  stop("Invalid 'frames' option.")

# if the user chooses the 'backward' option we duplicate the files 
#   in a temporary directory

if(opt$backward){
  npngs <- 2L * length(png_files)
  fmt <- paste0("pic%0", floor(log10(npngs) + 1), "d.png")
  new_png_files <- file.path(tempdir(), sprintf(fmt, 1L:npngs))
  file.copy(c(png_files, rev(png_files)), new_png_files)
  png_files <- new_png_files
}

# get width and height
wh <- as.numeric(strsplit(opt$size, "x")[[1L]])
# a function to avoid some printed messages
quiet <- function(x) {
  sink(tempfile())
  on.exit(sink())
  invisible(force(x))
}

# run gifski
quiet(gifski(
  png_files = png_files,
  gif_file = opt$output,
  width = wh[1L],
  height = wh[2L],
  delay = 1/opt$fps,
  loop = ifelse(opt$loop == 0L, TRUE, opt$loop)
))

cat("Output written to", opt$output)


