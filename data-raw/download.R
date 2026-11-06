# Fetch the raw IPO extracts from the GitHub release if they are not on disk.
# Release assets (tag data-v1), gzipped copies of the three IP India search exports:
#   IPR_published.csv.gz       Published Application Numbers Data (1960 to Aug 5, 2025)
#   IPR_granted.csv.gz         Granted Application Numbers Data (1960 to Aug 5, 2025)
#   IPR_granted_er_as.csv.gz   Granted + E-register + Application Status (Jan 1960 to Aug 15, 2025)
# Nothing in data-raw/ is committed; this script is the only tracked file there.
# Run it from the UniLemons project (open UniLemons.Rproj) or source() it by path; it locates the project root itself.

raw_files <- c("IPR_published.csv.gz", "IPR_granted.csv.gz", "IPR_granted_er_as.csv.gz")
release   <- "https://github.com/sonalisinghh/UniLemons/releases/download/data-v1"

# project root: the folder that holds UniLemons.Rproj, found from the project, this script's location, or the working directory
find_root <- function() {
  cands <- c(tryCatch(rprojroot::find_root(rprojroot::has_file("UniLemons.Rproj")), error = function(e) NA_character_),
             tryCatch(dirname(dirname(normalizePath(sys.frame(1)$ofile))), error = function(e) NA_character_),
             getwd(), dirname(getwd()))
  for (p in cands) if (!is.na(p) && file.exists(file.path(p, "UniLemons.Rproj"))) return(p)
  stop("cannot find UniLemons.Rproj; open the project or setwd() to the UniLemons folder")
}
raw_dir <- file.path(find_root(), "data-raw")
dir.create(raw_dir, showWarnings = FALSE, recursive = TRUE)

for (f in raw_files) {
  dest <- file.path(raw_dir, f)
  if (!file.exists(dest)) {
    message("downloading ", f, " to ", raw_dir)
    options(timeout = max(3600, getOption("timeout")))
    download.file(file.path(release, f), dest, mode = "wb", quiet = FALSE)
  }
}
stopifnot(all(file.exists(file.path(raw_dir, raw_files))))
message("raw data present in ", raw_dir)
