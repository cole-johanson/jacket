#' List the files in a directory
#'
#' This function automatically removes temporary files (i.e. those with '~' in the path)
#'
#' @param directory_path A string representing a directory (local or remote)
#' @param sub_dir An optional subdirectory. This is a separate parameter so we can loop over directories
#'               and access the same subdirectories (built for V:/.../sp/outputs/)
#' @param file_regex A string representing a regex to filter to
#' @param recursive Boolean. Whether to include sub-subdirectories
#'
#' @export
#'
list_files <- function(directory_path=getwd(), file_regex='.*', recursive=FALSE) {
  # Remove some tmp files ('~...rtf'); subset to '.rtf' files
  files = str_subset(
    str_subset(
      # subset to '.rtf' files
      list.files(directory_path, recursive=recursive),
      file_regex
    ),
    # Remove some tmp files ('~...rtf')
    '.*~.*', negate = TRUE
  )
  
  str_c(directory_path,files,sep='/')
}