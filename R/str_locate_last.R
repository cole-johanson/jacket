#' Locate the last location of a character in a string
#'
#' See \link[stringr]{str_sub}
#'
#' @param string Input vector. Either a character vector, or something coercible to one.
#' @param pattern Pattern (Character) to look for.
#'
#' @export
#'
str_locate_last <- function(string, pattern) {
  locs = stringr::str_locate_all(string , pattern)
  get_last <- function(m) {
    if(nrow(m) == 0) return(NA_integer_)
    max(m[,2])
  }
  as.integer(purrr::map(locs, get_last))
}