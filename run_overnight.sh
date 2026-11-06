#!/bin/bash
# Build before the 9am talk. Step 1: a 2-draw smoke run of 02 so any error shows up in the log within minutes.
# Step 2: trajectory balancing (100 draws). Step 3: 02 at 20 draws, which picks up the tjbal rows and the pre-slope labels.
# SDID at 200 draws takes hours on the full panel, so 02 stays at 20 draws tonight.
# Run from the project root:  caffeinate -i nohup ./run_overnight.sh > output/overnight.log 2>&1 &
cd "$(dirname "$0")"
mkdir -p output
echo "start $(date)"
Rscript -e 'rmarkdown::render("analysis/02_did_nirf.Rmd", output_dir = "output", output_file = "02_smoke.html", params = list(n_boot = 2))' > output/02_smoke.log 2>&1 \
  && echo "02 smoke ok $(date)" || { echo "02 SMOKE FAILED $(date); see output/02_smoke.log"; tail -40 output/02_smoke.log; exit 1; }
Rscript -e 'rmarkdown::render("analysis/03_tjbal.Rmd", output_dir = "output", params = list(n_boot = 100))' > output/03_tjbal.log 2>&1 \
  && echo "03 done $(date)" || { echo "03 FAILED $(date); see output/03_tjbal.log"; tail -40 output/03_tjbal.log; }
Rscript -e 'rmarkdown::render("analysis/02_did_nirf.Rmd", output_dir = "output", params = list(n_boot = 20))' > output/02_final.log 2>&1 \
  && echo "02 final done $(date)" || { echo "02 FINAL FAILED $(date); see output/02_final.log"; tail -40 output/02_final.log; }
echo "end $(date)"
