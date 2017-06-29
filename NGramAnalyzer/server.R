library(shiny)
library(DT)
library(biogram)

options(shiny.maxRequestSize=10*1024^2)

options(DT.options = list(dom = "Brtip",
                          buttons = c("copy", "csv", "excel", "print")
))

my_DT <- function(x)
  datatable(x, escape = FALSE, extensions = 'Buttons',
            filter = "none", rownames = FALSE)

source("functions.R")
load("pred_list.RData")

shinyServer(function(input, output) {
  
  prediction <- reactive({
    
    if (!is.null(input[["seq_file"]]))
      input_sequences <- read_txt(input[["seq_file"]][["datapath"]])
    input[["use_area"]]
    isolate({
      if (!is.null(input[["text_area"]]))
        if(input[["text_area"]] != "")
          input_sequences <- read_txt(textConnection(input[["text_area"]]))
    })
    
    if(exists("input_sequences")) {
      if(length(input_sequences) > 50) {
        #dummy error, just to stop further processing
        stop("Too many sequences.")
      } else {
        pred_vals(pred_list, extract_ngrams(input_sequences))
      }
    } else {
      NULL
    }
  })
  
  output$dynamic_ui <- renderUI({
    if (!is.null(input[["seq_file"]]))
      input_sequences <- read_txt(input[["seq_file"]][["datapath"]])
    input[["use_area"]]
    isolate({
      if (!is.null(input[["text_area"]]))
        if(input[["text_area"]] != "")
          input_sequences <- read_txt(textConnection(input[["text_area"]]))
    })
    
    if(exists("input_sequences")) {
      tags$p(HTML("<h3><A HREF=\"javascript:history.go(0)\">Start a new query</A></h3>"))
    }
  })
  
  output$pred_table <- DT::renderDataTable({
    pred_df <- prediction()
    browser()
    colnames(pred_df)
    formatRound(my_DT(pred_df), 2, 1L:nrow(pred_df))
  })
  
  
  
  output$dynamic_tabset <- renderUI({
    if(is.null(prediction())) {
      
      tabPanel(title = "Sequence input",
               tags$textarea(id = "text_area", style = "width:90%",
                             placeholder="Paste sequences (FASTA format required) here...", rows = 22, cols = 60, ""),
               p(""),
               actionButton("use_area", "Submit data from field above"),
               p(""),
               fileInput('seq_file', 'Submit .fasta or .txt file:'))
      
      
    } else {
      tabsetPanel(
        DT::dataTableOutput("pred_table")
      )
    }
  })
  
  
})