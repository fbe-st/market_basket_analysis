library(shiny)
library(shinyWidgets)
library(tidyverse)
library(arules)

options(shiny.maxRequestSize=256*1024^2)

ui <- fluidPage(
  tabsetPanel(
    tabPanel(
      title = "Explore Data",
      sidebarLayout(
        sidebarPanel(
          wellPanel(
            fileInput(
              inputId = "events_file", label = "Select events csv:"
              )
            ),
          wellPanel(
            uiOutput("ui_select_clients")
            )
          ),
        mainPanel(
          DT::dataTableOutput(outputId = "events_table_output")
          )
        )
      ),
    tabPanel(
      title = "Learn Rules",
      sidebarLayout(
        sidebarPanel(
          wellPanel(
            sliderInput("support_param", "Support threshold:",
                        min = 0, max = 1,
                        value = 0.05, step = 0.01),
            sliderInput("confidence_param", "Confidence threshold:",
                        min = 0, max = 1,
                        value = 0.25, step = 0.01),
            sliderInput("minlen_param", "Minimum length of sequence:",
                        min = 2, max = 5,
                        value = 2, step = 1),
            sliderInput("maxlen_param", "Maximum length of sequence:",
                        min = 6, max = 20,
                        value = 10, step = 1),
            numericInput(inputId = "head_param", label = "Show lift top n:", 
                         value =  20, min = 10, step = 1)
            )
          ),
        mainPanel(
          DT::dataTableOutput(outputId = "inspect_rules")
          )
        )
      )
    )
  )

server <- function(input, output, session) {
  
  get_events_csv <- eventReactive(input$events_file, {
    #print("Calling: get_events_csv")
    
    input_files <- input$events_file
    data_paths <- input_files$datapath
    events_df <- read_csv(data_paths)
  })
  
  
  output$ui_select_clients = renderUI({
    tagList(
      pickerInput(inputId = "clients_selected", label = "Select clients to analyse:", 
                  choices = unique(get_events_csv()$client_name), 
                  options = list(`actions-box` = TRUE),
                  multiple = TRUE, selected = unique(get_events_csv()$client_name)),
      dateRangeInput(inputId = "date_ranges", label = "Select time period:", 
                     start = min(get_events_csv()$event_timestamp, na.rm = TRUE)
      )
    )
  })
  
  
  filter_events_df <- reactive({
    #print("Calling: filter_events_df")
    
    events_df <- get_events_csv()
    events_df <- events_df %>% 
      filter(client_name %in% input$clients_selected) %>% 
      filter(event_timestamp >= input$date_ranges[1], event_timestamp <= input$date_ranges[2])
  })
  
  
  output$events_table_output = DT::renderDataTable(
    filter_events_df(),  
    filter = "top"
  )
  
  
  get_rules <- reactive({
    
    events_df_filtered <- filter_events_df() %>% 
      mutate(wi_event_name = paste0(event_object_description, "__", event_name)) %>% 
      mutate(session_uuid = paste0(user_id, "_", session_id)) %>%
      as.data.frame()
    
    
    trans <- as(split(events_df_filtered[,"wi_event_name"], events_df_filtered[,"session_uuid"]), "transactions")
    rules <- apriori(trans, parameter = list(support = input$support_param, 
                                             confidence = input$confidence_param, 
                                             minlen = input$minlen_param, 
                                             maxlen = input$maxlen_param))
  })
  
 
  output$inspect_rules <- DT::renderDataTable({
    
    quiet <- function(x) { 
      sink(tempfile()) 
      on.exit(sink()) 
      invisible(force(x)) 
    } 
    
    rules <- quiet(get_rules())
    
    head_n <- min(input$head_param, length(rules))
    
    rules %>% 
      sort(., by = "lift") %>% 
      .[1:head_n] %>% 
      as(., "data.frame")
  })
  
}

shinyApp(ui, server)

