# Fetch the raw IPO extracts from the GitHub release if they are not on disk.
# Release assets (tag data-v1), gzipped copies of the three IP India search exports:
#   IPR_published.csv.gz      Published Application Numbers Data (1960 to Aug 5, 2025)
#   IPR_granted.csv.gz        Granted Application Numbers Data (1960 to Aug 5, 2025)
#   IPR_granted_er_as.csv.gz  Granted + E-register + Application Status (Jan 1960 to Aug 15, 2025)
# Nothing in data-raw/ is committed; this script is the only tracked file there.

raw_files <- c("IPR_published.csv.gz", "IPR_granted.csv.gz", "IPR_granted_er_as.csv.gz")
release   <- "https://github.com/sonalisinghh/UniLemons/releases/download/data-v1"
raw_dir   <- here::here("data-raw")

for (f in raw_files) {
  dest <- file.path(raw_dir, f)
  if (!file.exists(dest)) {
    message("downloading ", f)
    options(timeout = max(3600, getOption("timeout")))
    download.file(file.path(release, f), dest, mode = "wb", quiet = FALSE)
  }
}
stopifnot(all(file.exists(file.path(raw_dir, raw_files))))
