jacket_palette = c(
  # In Rainbows inspired, created from coolors.co
  "background"= "#38405F",
  "foreground" = "#C6362F",
  "highlight" = "#E7940D",
  "neutral" = "#f5f5f8",
  "light_accent" = "gray"
)

#' fluidPage head style
#'
#' Used in the app's ui tags$head(tags$style())
#'
#' @export
fluid_page_head_style <- function() {
  str_c('
    /*set style for uploader*/ 
    div#uploader {
      position: absolute;
      top:  50%;
      left: 50%;
      transform: translate(-50%,-50%);
    }
  
    /*DT download button*/
    button.dt-button {
      background-color: white !important;
      color: black !important;
    }
    button.dt-button:hover {
      background-color: white !important;
      color: black !important;
    }
    
    /*DT header*/
    thead {
      background-color: white;
    }
    
    /*Set the sidepanel style*/
    #sidebar {
      background-color: ',jacket_palette['foreground'],';
      color: white;
      border: 1px solid white;
    }
    
    /*Set the non-selected tab style*/
    .nav-tabs>li>a {
      background-color: ',jacket_palette['light_accent'],';
      color: ',jacket_palette['foreground'],'; font-weight: bold;
    }
    
    /*Set the selected tab style*/
    .tabbable>.nav>li[class=active]>a {
      color: ',jacket_palette['highlight'],'; 
      font-weight: bold;
      border-bottom-color: white;
    }
    
    /*Remove the single line under tabs*/
    .nav-tabs {
        border-bottom: 0px 
    }
    
    /*Style the top-most tabset*/
    #main_tabs>li>a {
      border-radius: 0 0 0 0;
      background-color: ',jacket_palette['light_accent'],';
      width: 32vw;
      color: white; 
      /*border: 0px;*/
    }
    #main_tabs>li[class=active]>a {
      background-color: ',jacket_palette['foreground'],';
      color: white; 
      font-weight: bold;
    }
    
    /*Set the general font preferences: font white except for modal*/
    body, label, input, button, select {
      font-family: "Aileron",Helvetica,Arial,sans-serif;
      color: white;
    }
    .modal-content{
      color: black;
    }
    .modal-content label{
      color: black;
    }
    
    /*Set the width of the modal to fit the content*/
    .modal-dialog { width: fit-content !important; }
    
    /*Set the style for the "Edit" buttons on the inputs data frames*/
    button {
      background-color: ',jacket_palette['neutral'],';
      color: black;
    }
    
    /*Add the expand triangle to the sidePanel elements*/
    summary {
      display: revert
    }
    
    /*Style the output links*/
    #output_links>ul {
      padding-inline-start: 17px;
      list-style-type: none;
      margin-bottom: 0px;
    }
    a {
      color: white;
      font-weight: bold;
    }
    a:hover {
      color: white;
    }
  ')
}

#' fluidPage style
#'
#' Used in the app's ui tags$style()
#'
#' @export
fluid_page_style <- function() {
  str_c('
    #fullpage { background-color: ', jacket_palette['background'],'; }
    .webpro_navbar {
      background-color: ', jacket_palette['neutral'],'; }
    }
  ')
}

header_bar_html <- function(text, background_color= jacket_palette['highlight'], text_color=jacket_palette['neutral']) {
  HTML(str_glue('
    <nav class="navbar navbar-light" style="background-color:{background_color}">
      <span class="navbar-brand mb-0 h1" style="color:{text_color}; font-size: 60px;"><b>{text}</b></span>
    </nav>
  '))
}

title_html  <- function(text, text_color='white') {
  HTML(str_glue('
    <h4 style="color:{text_color}"><b>{text}</b></h4>
  '))
}
