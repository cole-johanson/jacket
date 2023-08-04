#' @export
file_read <- function(file_path) {
  suffix = file_get_suffix(file_path)
  if(suffix == "sas7bdat") {
    return(haven::read_sas(file_path))
  } else if(suffix == "xlsx") {
    return(readxl::read_excel(file_path))
  } else if(suffix == "csv") {
    return(readr::read_csv(file_path))
  } else {
    rlang::abort('Unsupoorted file type')
  }
}

