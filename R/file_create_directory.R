#' Create directories
#'
#' Creates local directories (if needed) based on file path(s)
#'
#' @param file a single string or a vector of strings representing file names
#'
#' @export
file_create_directory <- function(file) {
  dir_to_create = file_get_directory_path(file)
  if(!is.na(dir_to_create)) fs::dir_create(dir_to_create)
}
