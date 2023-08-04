#' File copy
#'
#' Wrapper around fs::file_copy to fs::dir_create() if necessary
#'
#' @param ... see \link[fs]{file_copy}
#'
#' @export
#'
file_copy <- function(...) {
  args = list(...)
  if(length(args) < 2) {
    rlang::abort('file_copy requires at least two arguments')
  }
  # Hack to get the new_path based on position or name
  to = NULL
  if(!is.null(args[['to']])) {
    to = args[['to']]
  } else {
    to = args[[2]]
  }
  file_create_directory(to)
  
  args = args |> append(list(copy.mode = F))
  
  do.call(file.copy, args)
}
