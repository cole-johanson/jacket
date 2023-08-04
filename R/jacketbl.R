jacketbl_ui <- function(id) {
  ns <- NS(id)
  # Add code for the Next button in the modal (+val treats val as an integer)
  tagList(
    shinyjs::extendShinyjs(text = paste0("shinyjs.increase_row = function(val){
        Shiny.setInputValue('", ns("edit_button_click"), "', +val + 1, { priority: 'event' })
      }"), functions = "increase_row"
    ),
    fluidRow(
      reactable::reactableOutput(ns("table"))
    ),
  )
}

jacketbl_server <- function(id, .col_data, content_) {
  moduleServer(
    id,
    function(input, output, session) {
      input_name = stringr::str_replace(id,"tbl_","")
  
      # Add the edit button column
      data <- cbind(.col_data, edit_button = NA)
      
      # Add some environment variables, which are returned back to the main server function:
      #    `data` - The input data frame (is this what is edited?), 
      #    `modal_closed` a boolean whether the modal for editing a column is being closed (set below)
      #    `selected_rows` is stored for updating the data frame after the edit button is clicked, and in 
      #                    the main server function
      #    `current_page` is stored for updating the data frame after the edit button is clicked
      values <- reactiveValues(
          dataframe = data, 
          modal_closed = NULL,
          current_page = 1
        )
      selected_rows = reactive({reactable::getReactableState("table")$selected})
      
      # The table for the columns should display like this initially, and have this logic for the edit 
      # button. Namely, the JS handle clicks of the edit button by updating the Shiny module's 
      # input$edit_button_click with an "index" of the row selected. (See below for what we do with this.)
      output$table <- reactable::renderReactable(
        reactable::reactable(
          data, 
          columns = list(
            edit_button = reactable::colDef(
              name = "", 
              sortable = F, 
              cell = function() htmltools::tags$button(id = session$ns("button"), "Edit Output Column Title")
            )
          ),
          defaultPageSize = 20,
          defaultSelected = 1:nrow(data),
          style = as.character(str_glue("background-color: {jacket_palette['background']}")),
          selection = "multiple",
          onClick = reactable::JS(
            paste0("function(rowInfo, column) {
              // Only handle click events on the 'edit_button' column
              if (column.id !== 'edit_button') {
                return
              }
              // Send the click event to Shiny; add 1 to index since JS indexes start at 0
              if (window.Shiny) {
                Shiny.setInputValue('", session$ns("edit_button_click"),"', rowInfo.index + 1, { priority: 'event' })
              }
            }")
          )
        )
      )
      output_updates = reactive({list(selected_rows(), values$dataframe)})
      
      # When there are updates to the output, make sure the content_$output_data is updated appropriately
      observeEvent(output_updates(), {
        content_$output_data[[input_name]] = content_$full_data[[input_name]] |> 
          set_col_names_as(values$dataframe[,2])  |>
          select(selected_rows())
      })
      
      # If a edit button is clicked... (This variable is a list with one value: "index", the index row) 
      observeEvent(input$edit_button_click, {
        # Set the modal_closed boolean to F before we show it
        values$modal_closed = FALSE
        reactable_state = reactable::getReactableState("table")
        values$current_page = reactable_state$page
        # Show the modal for editing a given value
        showModal(
          modalDialog(
            title = "Edit Values",
            div(
              style="display:inline-block;vertical-align:top;",
              splitLayout(
                cellWidths = (c("90%","10%")),
                textInput(
                  inputId = session$ns("output_col"), 
                  label = values$dataframe[input$edit_button_click, "Column name"], 
                  value = values$dataframe[input$edit_button_click, "Output Column Title"]
                ),
                div(
                  style="position: absolute; bottom: 28%;",
                  actionButton(
                    session$ns("increase_index"), label=" ", icon = icon("arrow-right")
                  )
                )
              )
            ),
            easyClose = TRUE,
            size = 's',
            footer = actionButton(session$ns("save"), "Save")
          )
        )
      })
      
      # When we hit the Next button, increase the edit_button_click by 1
      observeEvent(input$increase_index, {
        values$modal_closed <- TRUE
        removeModal()
        shinyjs::js$increase_row(input$edit_button_click)
      })
      
      # When we hit save...
      observeEvent(input$save, {
        values$modal_closed <- TRUE
        removeModal()
      })
      observeEvent(values$modal_closed, {
        if (values$modal_closed == TRUE) {
          values$dataframe[input$edit_button_click, "Output Column Title"] <- input$output_col
      
          # Update the table that's displayed, but keep the same page and selected rows
          reactable::updateReactable(
            "table", 
            values$dataframe, page = values$current_page, selected = selected_rows()
          )
        }
      })
      
      return(content_)
    }
  )
}
