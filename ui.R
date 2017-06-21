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
                           fluidRow(
                             column(width = 7,
                                    h4("Top 15 Tweets with #hashtag"),
                                    div(dataTableOutput("top_15_tweets"), style = "font-size: 80%; width: 100%")),
                             column(width = 5,
                                    h4("Most Popular #hashtags Associated with #hashtag"),
                                    div(dataTableOutput("top_15_hashes"), style = "font-size: 80%; width: 100%")))), 
                  
                  tabPanel("Florida Tweets",  
                           h4("Where are users tweeting their location?"),
                           leafletOutput("fla_map"),
                           h4("Twitter User Names"),
                           dataTableOutput("fla_users")), 
                  
                  tabPanel("Trending Topics",
                           fluidRow(
                             
                             column(width = 4,
                                    h4("Top 10 Trending Topics United States"),
                                    div(dataTableOutput("usa_topics"),  style = "font-size: 80%; width: 100%")),
                             
                             column(width = 4,
                                    h4("Top 10 Trending Topics in Location 1"),
                                    div(dataTableOutput("loc1_topics"), style = "font-size: 80%; width: 100%")),
                             
                             column(width = 4,
                                    h4("Top 10 Trending Topics in Location 2"),
                                    div(dataTableOutput("loc2_topics"), style = "font-size: 80%; width: 100%")))
        )
      )
    )
  )
)