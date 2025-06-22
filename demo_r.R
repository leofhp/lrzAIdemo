library(CICI)
library(this.path)

main <- function(base_dir) {
  data(EFV)
  est <- gformula(
    X = EFV, Lnodes = c("adherence.1", "weight.1", "adherence.2", "weight.2", "adherence.3", "weight.3", "adherence.4", "weight.4"),
    Ynodes = c("VL.0", "VL.1", "VL.2", "VL.3", "VL.4"),
    Anodes = c("efv.0", "efv.1", "efv.2", "efv.3", "efv.4"),
    abar = seq(0, 9, 3), B = 40, ncores = 4, verbose = TRUE
  )
  write.csv(est$results, file.path(base_dir, "demo_r_results", "results.csv"), row.names = FALSE)
}

if (sys.nframe() == 0) {
  base_dir <- dirname(this.path())
  main(base_dir)
}