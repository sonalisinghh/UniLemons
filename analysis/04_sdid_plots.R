# Synthetic DiD plots in the synthdid package's own style (Arkhangelsky et al. 2021, Fig. 1):
# treated path, weighted-control path, time weights as the shaded area, and the DiD parallelogram.
# Point estimates only (no bootstrap), so it runs in minutes. Six main cuts, filings and granted.
# Run from the project root:  Rscript analysis/04_sdid_plots.R
suppressPackageStartupMessages({ library(here); library(data.table); library(ggplot2); library(synthdid) })
panel <- readRDS(here("data", "panel_inst_year.rds"))
grant_safe <- as.integer(stringr::str_extract(readLines(here("data", "README_panel.txt"))[6], "[0-9]{4}$"))
d <- panel[year %between% c(2005, 2020) & class %chin% c("edu_elite", "edu_central", "edu_state", "edu_private", "firm") & group != "Startup firm (excluded)"]
cuts <- list(
  list(label = "All universities", sel = quote(treat == 1)),
  list(label = "Central",          sel = quote(treat == 1 & ownership == "central")),
  list(label = "State",            sel = quote(treat == 1 & ownership == "state")),
  list(label = "Private",          sel = quote(treat == 1 & ownership == "private")),
  list(label = "Elite (SIR 2010)", sel = quote(elite == 1)),
  list(label = "Non-elite",        sel = quote(treat == 1 & elite == 0)))
slug <- function(x) gsub("[^a-z0-9]+", "_", tolower(x))
ser <- list()
for (y in c("filings", "granted")) {
  ests <- list()
  for (cc in cuts) {
    s <- d[eval(cc$sel) | class == "firm"]; if (y == "granted") s <- s[year <= grant_safe]
    W <- dcast(s, inst_id + treat ~ year, value.var = y); setorder(W, treat, inst_id)
    Y <- as.matrix(W[, -(1:2)]); N0 <- sum(W$treat == 0); T0 <- sum(as.integer(colnames(Y)) < 2015)
    est <- synthdid_estimate(Y, N0, T0)
    ests[[cc$label]] <- est
    # weighted-control and treated paths for the counterfactual table
    om <- attr(est, "weights")$omega; lam <- attr(est, "weights")$lambda
    ser[[paste(cc$label, y)]] <- data.table(group = cc$label, outcome = y, year = as.integer(colnames(Y)),
                                            universities = colMeans(Y[-(1:N0), , drop = FALSE]),
                                            sdid_weighted_firms = as.numeric(t(Y[1:N0, ]) %*% om),
                                            firms_unweighted = colMeans(Y[1:N0, , drop = FALSE]))
    cat(y, cc$label, "ATT", round(as.numeric(est), 3), "\n")
  }
  g <- synthdid_plot(ests, facet.vertical = FALSE, control.name = "domestic firms (SDID-weighted)", treated.name = "universities",
                     lambda.comparable = TRUE, se.method = "none", trajectory.linetype = 1, line.width = 0.6, effect.curvature = -0.4,
                     trajectory.alpha = 0.8, effect.alpha = 0.6, diagram.alpha = 0.8, onset.alpha = 0.4) +
    facet_wrap(~ facet, scales = "free_y", ncol = 3) + theme_minimal(base_size = 11) + theme(legend.position = "bottom") +
    labs(x = NULL, y = paste0(if (y == "filings") "Filings" else "Filings later granted", " per university-year"),
         title = paste0("Synthetic DiD: universities vs SDID-weighted domestic firms, ", if (y == "filings") "filings" else paste0("filings later granted (cohorts to ", grant_safe, ")")),
         subtitle = "Shaded area at the bottom: SDID time weights on pre-years. Arrow: estimated ATT (post-2015 average)")
  ggsave(here("output", "figures", paste0("fig_sdid_", y, ".png")), g, width = 12, height = 7, dpi = 200, bg = "white")
}
fwrite(rbindlist(ser), here("output", "tables", "t8f_sdid_series.csv"))
cat("done\n")
