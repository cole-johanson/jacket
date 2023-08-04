#' Read SAS
#'
#' Read a SAS file
#'
#' @param ... strings to be pasted together to form a path (via `fs::path(...)`)
#'
#' @export
read_sas <- function(..., n_max = Inf) {
  path_ = fs::path(...)
  if(!str_detect(path_,'\\.sas7bdat$')) path_ = str_c(path_,'.sas7bdat')
  haven::read_sas(path_, n_max = n_max)
}