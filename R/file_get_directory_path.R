#' Get file directory
#'
#' Get the file directory given a full file path
#'
#' @param p a character vector representing a file path
#'
#' @export
file_get_directory_path <- function(p) {
  str_sub(p, end = str_locate_last(p,'/') - 1)
}
