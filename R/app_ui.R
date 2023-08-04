#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {
  tagList(
    golem_add_external_resources(),
    fluidPage(
      id="fullpage",
      tags$header(tags$script(type = "text/javascript", js_focus_modal)),
      shinyjs::useShinyjs(),
      waiter::useWaiter(),
      shinyWidgets::setBackgroundColor(jacket_palette['background']),
      tags$head(tags$style(HTML(fluid_page_head_style()))),
      tags$style(fluid_page_style()),
      htmltools::h3('Jacket File Editor / Zipper', style = 'text-align: center; color:white; font-weight: 900')
    ),
    sidebarLayout(
      sidebarPanel(
        style = "overflow-y:scroll; max-height: 80vh; position:relative;",
        width = 3,
        id="sidebar",
        fileInput(
          inputId = "uploads", 
          label = "Upload dataset(s) for editing", 
          multiple = T,
          accept=c('csv', 'comma-separated-values','.csv', "text/xlsx",".xlsx", ".sas7bdat")
        ),
        detail_summary(
          'Files',
          shiny::checkboxGroupInput(
            "file_select", 
            label = NULL,
            choices = c() # TODO: update with content_$files_list in the app_server
          )
        ),
        detail_summary(
          'Data Listings',
          uiOutput('output_links')
        ),
        br(),
        htmlOutput("querylog", inline=T),
        downloadLink("download_all","Download all")
      ),
      mainPanel(
        tabsetPanel(id="main_tabs",
          tabPanel(
            "Files",
            br(),
            tags$div(class = 'tabset'), do.call(shiny::tabsetPanel, list(id="input_tabs"))
          ),
          tabPanel(
            "Data Listings",
            br(),
            tags$div(class = 'tabset'), do.call(shiny::tabsetPanel, list(id="output_tabs"))
          )
        )
      )
    )
  )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www",
    app_sys("app/www")
  )

  tags$head(
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "jacket"
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
  )
}
