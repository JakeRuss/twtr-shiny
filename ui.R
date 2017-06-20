library(shiny)

# Define UI for random distribution application 
fluidPage(
  
  # Application title
  titlePanel("Twitter Dashboard"),
  
  # Sidebar with controls to select the random distribution type
  # and number of observations to generate. Note the use of the
  # br() element to introduce extra vertical spacing
  sidebarLayout(
    sidebarPanel(
      
      # Text box for hashtag input
      textInput(inputId = "hash_tag",
                label   = "Hashtag:", 
                value   = "rstats"),
      
      numericInput(inputId = "number_of_tweets",
                   label   = "How many tweets to include in the search?",
                   min     = 100,
                   max     = 2000,
                   value   = 1000),
      
      br(),
      
      # Slider input for streaming amount 
      sliderInput(inputId = "stream_amount",
                 label    =  "How long should I collect tweets? (seconds):", 
                 min      = 5, 
                 max      = 60, 
                 value    = 30),
      
      br(),
      
      # Input for trends
      textInput("city_1", "Location One (woeid):", value = "2503713"),
      
      br(),
      
      textInput("city_2", "Location Two (woeid):", value = "2503863"),
      
      br(),
      
      actionButton("refresh", "Refresh Tweets Now!")

    ),
    
    # Show a tabset that includes three tabs
    mainPanel(
      tabsetPanel(type = "tabs", 
                  tabPanel("Hashtag Search", 
                           h2("Top 15 Tweets with #hashtag"),
                           tableOutput("top_15_tweets"),
                           h2("Top 15 Other #hashtags associated with #hashtag"),
                           tableOutput("top_15_hashes")), 
                  
                  tabPanel("Florida Tweets",  leafletOutput("fla_map")), 
                  
                  tabPanel("Trending Topics", tableOutput("usa_topics"),
                                              br(),
                                              tableOutput("loc1_topics"),
                                              br(),
                                              tableOutput("loc2_topics"))
      )
    )
  )
)