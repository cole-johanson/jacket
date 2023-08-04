#' Remove file suffix
#'
#' @param f A path or file name
#'
#' @export
file_remove_suffix <- function(f) {
  # For some reason, this isn't implicitly vectorized
  purrr::map_chr(f, ~str_sub(.x, end=str_locate_last(.x,'\\.')[1]-1))
}