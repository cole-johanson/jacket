#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  # Initialize empty vector
  content_ = reactiveValues(
    uploads = tibble::tibble(name=character(), size=integer(), type=character(), datapath=character()),
    columns = list(), # Name + columns data frame
    full_data = list(), # Raw
    output_data = list(), # Edited (columns + full_data)
    inputs_clicked = character(), # sidePanel list of inputs that were clicked (to measure change)
    outputs_clicked = character(), # sidePanel output last clicked (to measure change)
  )
  
  # Save the new uploads appropriately
  observeEvent(
    input$uploads,
    {
      new_files = input$uploads$name
      
      # Do some checks for duplicates 
      dupe_files = new_files[which(new_files %in% content_$files_list)]
      if(length(dupe_files) > 0) {
        shinyalert(
          "Duplicate file", 
          "Duplicate file name(s) found: {str_c(dupe_files, collapse = '\n')}. The new file(s) will replace the existing file(s).", 
          type = "warning"
        )
      }
      dupe_new_files = new_files[which(duplicated(new_files))]
      if(length(dupe_new_files) > 0) {
        shinyalert(
          "Duplicate file", 
          "Duplicate file name(s) found: {str_c(dupe_new_files, collapse = '\n')}. The first file(s) will be used.", 
          type = "warning"
        )
      }

      # uploads contains the latest version of each file (see shiny::fileInput for dataframe description)
      content_$uploads = content_$uploads |> 
        bind_rows(input$uploads) |>
        mutate(file_wo_suffix = file_remove_suffix(name)) |>
        group_by(file_wo_suffix) |>
        slice_tail()
      
      # Set a list with all the new data frames
      new_data_ = purrr::map(content_$uploads$datapath, file_read) |>
        rlang::set_names(nm = content_$uploads$file_wo_suffix)
      
      # Save the content_$columns and content_$full_data
      for(i in 1:length(new_data_)) {
        dataset = new_data_[[i]]
        col_df = tibble::tibble(`Column name` = character(), `Output Column Title` = character())
        for(col_num in 1:ncol(dataset)) {
          col_name = colnames(dataset)[col_num]
          col_label = attr(dataset |> dplyr::pull(col_num),"label")
          col_name_label = {if(is.null(col_label)) {col_name} else {str_glue('{col_name} ({col_label})')}}
          if(is.null(col_label)) col_label = NA_character_
          col_df = col_df |> dplyr::bind_rows(tibble::tibble(
            `Column name` = col_name, 
            `Output Column Title` = col_name_label
          ))
        }
        content_$columns[[names(new_data_)[i]]] = col_df
        content_$full_data[[names(new_data_)[i]]] = dataset
      }
      
      # Initialize the new output_data (but leave existing output_data untouched)
      for(new_file in new_files) {
        new_file_wo_suffix = file_remove_suffix(new_file) 
        content_$output_data[new_file_wo_suffix] = content_$full_data[new_file_wo_suffix]
      }
      
      # Update the file selection with the new values (but maintain the current selections where applicable) 
      updateCheckboxGroupInput(
        inputId = "file_select",
        choices = content_$uploads$file_wo_suffix,
        selected = intersect(input$file_select, content_$uploads$file_wo_suffix)
      )
    }
  )
  
  # When the side panel inputs (Files) checkboxes changes, we are either adding or removing a value. When 
  # this happens, we need to either add/remove an input/output tab, and an output link on the sidePanel.
  observeEvent(
    input$file_select, ignoreNULL = F, ignoreInit = T,
    {
      # Find whether the change is a new checkbox or a removed checkbox. (To do this, we store/maintain the
      # existing files list content_$inputs_clicked to diff from.)
      selected_files = {if(is.null(input$file_select))  {character()} else {input$file_select}}
      new_val = setdiff(selected_files, content_$inputs_clicked)
      removed_val = setdiff(content_$inputs_clicked, selected_files)
    
      # Render the output links in the sidePanel (reacts to which files are selected, and the file names)
      output$output_links =  renderUI({
        tags$ul(
          purrr::map(selected_files, ~tags$li(actionLink(inputId = str_glue("action_{.x}"), label = input[[str_glue('filename_{.x}')]])))
        )
      })
      
      # If it's a new_val
      if(length(new_val) > 0) {
        # Update the existing files list (for next time)
        content_$inputs_clicked = c(content_$inputs_clicked, new_val)
        
        # Add an inputs tab, wtih a textInput for the output file name and the jacketbl of columns to edit
        appendTab(
          inputId = "input_tabs",
          tab = tabPanel(
              title = new_val,
              br(),
              shiny::textInput(
                inputId = str_glue('filename_{new_val}'),
                label = "Output name",
                value = new_val
              ),
              jacketbl_ui(as.character(str_glue("tbl_{new_val}")))
            ),
          select=T
        )
        
        # Start the input module server
        output_name <- paste0("tbl_", new_val)
        content_ = jacketbl_server(output_name, content_$columns[[new_val]], content_)
        
        # Register a new output of the rendered text from the output file name (for the output tab to react)
        output[[str_glue('tab_{new_val}')]] = renderText(input[[str_glue('filename_{new_val}')]])
        
        # Add an outputs tab
        appendTab(
          inputId = "output_tabs",
          tab = tabPanel(
            title = uiOutput(str_glue('tab_{new_val}')),
            value = new_val,
            DT::renderDataTable(jacket_dt(content_$output_data[[new_val]]))
          ),
          select=T
        )
        
        # The output links in the sidePanel need to react to being clicked. Observe clicks and select the 
        # appropriate tabs when clicked. FYI - We have no destroyer, so this will probably register multiple
        # of these events if a user deselects / reselects inputs. Doesn't seem to be an issue
        observeEvent(input[[str_glue("action_{new_val}")]], {
          # Select the Outputs tab
          shiny::updateTabsetPanel(
            inputId = "main_tabs",
            selected = "Data Listings"
          )
          # Select the output of interest
          shiny::updateTabsetPanel(
            inputId = "output_tabs",
            selected = input[[str_glue('filename_{new_val}')]]
          )
        })
        
      # If it's a removed_val
      } else if(length(removed_val) > 0) {
        # Update the known values (for next time)
        content_$inputs_clicked = setdiff(content_$inputs_clicked, removed_val)
        # Remove the inputs tab
        removeTab(
          inputId = "input_tabs",
          target = removed_val
        )
        # Remove the outputs tab
        removeTab(
          inputId = "output_tabs",
          target = removed_val
        )
      }
    }
  )
  
  # The shiny::downloadHandler() takes a function for serving the filename and a function for serving the
  # content. 
  output$download_all <- downloadHandler(
    # Define the name of the zip file
    filename <- function(file) {
      
      return(str_glue('jacket_{format(Sys.Date(),"%Y%m%d")}.zip'))
    },
    
    content <- function(file) {
      # Add a waiter to show the user we're calculating output
      waiter::waiter_show(html = waiter::spin_5())
      
      # A function to write the Excel files using the chosen files name and output data
      write_excel <- function(input_id) {
        # Get the filename
        filename = tmpfile_path(str_glue('{input[[paste0("filename_",input_id)]]}.xlsx'))
        openxlsx::write.xlsx(
          x = content_$output_data[[input_id]],
          file = filename
        )
        return(filename)
      }
      filenames = unlist(purrr::map(input$file_select, write_excel))

      zip(
        zipfile = tmpfile_path('tmp.zip'), 
        files = filenames,
        extras = "-j" # Ignore file paths when saving zip
      )
      file.copy(tmpfile_path('tmp.zip'), file) # shiny::downloadHandler works by copying the contents back to the input
      file.remove(tmpfile_path('tmp.zip'))
      waiter::waiter_hide()
    }
  )
}
