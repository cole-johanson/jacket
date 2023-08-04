#' DT for Corcept
#'
#' Wrap a DT object with some additional functionality specific to Corcept
#'
#' @param x a data frame or .webpro_comparison object (created from `webpro_compare()`)
#'
#' @export
#'
jacket_dt <- function(x, cols) {
  x = x |>
    DT::datatable(
      extensions = list('FixedHeader' = NULL,'Buttons' = NULL),
      options = list(
        # https://datatables.net/reference/option/
        autoWidth = TRUE,
        #fixedHeader = TRUE, # FixedHeader extension to maintain header when scrolling; this was causing issues
         columnDefs = list(list(orderable = F, targets = "_all")),
        # columnDefs = list(list(visible=FALSE, targets=cols_to_hide-1)),
        paging = FALSE, # Turn off the pagination
        info = FALSE, # Remove the "Showing 1 to 4 of 4 entries"
        dom = 'rtip'
        # TODO: maybe add global search? https://stackoverflow.com/questions/37521186/keep-search-value-between-tabs
      ),
      rownames=FALSE, # Remove rownames / numbering on the LHS
      filter = list(
        position = 'top', clear = FALSE
      )
    )
  
  return(x)
}
