#' Get file name
#'
#' Get the file name from a file path
#'
#' @param p a character vector representing a file path
#'
#' @export
file_get_name <- function(p) {
  str_sub(p, start = str_locate_last(p,'/') + 1)
}
