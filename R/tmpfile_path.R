#' @export
tmpfile_path <- function(filename) {
  fs::path(tempdir(), filename)
}