#' @export
detail_summary <- function(title, ...) {
  tagList(
    HTML(str_glue('<details><summary>{title}</summary><blockquote">')),
    ...,
    HTML('</blockquote></details>')
  )
}
