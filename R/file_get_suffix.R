#' Get file suffix
#'
#' Get the suffix of a file name or file path
#'
#' @param p a character vector representing a file name or file path
#'
#' @export
file_get_suffix <- function(p) {
  str_sub(p, start = str_locate_last(p,'\\.') + 1)
}