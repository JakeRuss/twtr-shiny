library(shiny)
library(dplyr)
library(tidyr)
library(rtweet)
library(leaflet)
library(stringr)

# Define server logic for random distribution application
function(input, output) {
  
  # Panel 1: Hashtag "analysis" ----------------------------------------------
  hashtag_tweet_data <- reactive({
    # For manual refreshing
    input$refresh
  
    search_term <- paste0("#", input$hash_tag)
    
    htag_data <- search_tweets(search_term, n = input$number_of_tweets)
    
    htag_data
  })
   
  # Generate an HTML table view of the data
  output$top_15_hashes <- renderTable({
    
    hashtag_tweet_data() %>%
      pull(hashtags) %>%
      strsplit("\\s") %>%
      unlist() %>%
      as_data_frame() %>%
      rename(hashtag = value) %>%
      mutate(hashtag = str_to_lower(hashtag)) %>%
      filter(!(hashtag %in% "rstats"), !is.na(hashtag)) %>%
      group_by(hashtag) %>%
      summarise(n = n()) %>%
      arrange(-n) %>%
      slice(1:15)}, caption = "Sample Data")
  
  
  output$top_15_tweets <- renderTable({
    
    hashtag_tweet_data() %>%
      filter(!is_retweet) %>%
      select(screen_name, text, retweet_count, hashtags) %>%
      arrange(desc(retweet_count)) %>%
      slice(1:15)
    
  }) 
    
  
  
  
  
}