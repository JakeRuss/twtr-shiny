library(shiny)
library(dplyr)
library(tidyr)
library(rtweet)
library(leaflet)
library(stringr)

options(shiny.sanitize.errors = FALSE)

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
  output$top_15_hashes <- renderDataTable({
    
    hashtag_tweet_data() %>%
      pull(hashtags) %>%
      strsplit("\\s") %>%
      unlist() %>%
      as_data_frame() %>%
      rename(hashtag = value) %>%
      mutate(hashtag = str_to_lower(hashtag)) %>%
      filter(!(hashtag %in% input$hash_tag), !is.na(hashtag)) %>%
      group_by(hashtag) %>%
      summarise(n = n()) %>%
      arrange(-n) %>%
      slice(1:15)
  })
  
  output$top_15_tweets <- renderDataTable({
    
    hashtag_tweet_data() %>%
      filter(!is_retweet) %>%
      select(screen_name, text, retweet_count, hashtags) %>%
      arrange(desc(retweet_count)) %>%
      slice(1:15)
    
  }) 
  
  # Panel 2: Map of Tweets ----------------------------------------------------
  
  appname <- "jakes_rtweet"
  key     <- "Z41oe0Z1QChhBoRGeMpBLAqHz"
  secret  <- "FXmhbJm2hIVRxAIBvVWs5wIPGAHbk42zgZ4QXWKcdCLIphQZno"
  
  twitter_token <- appname %>%
    create_token(consumer_key = key, consumer_secret = secret)
  
  # Put all streaming Tweets from Florida on a Leaflet Map
  fla_tweets_data <- reactive({
    # For manual refreshing
    input$refresh
    
    stream_tweets <- 
      stream_tweets(q       = c(-87.8,24.4,-79.8,31.1),  # Florida
                    timeout = input$stream_amount, 
                    token   = twitter_token)
    
  })
  
  output$fla_map <- renderLeaflet({
    
    fla_tweets_data() %>%
      filter(!is.na(coordinates)) %>%
      separate(coordinates, into = c("lat", "lon"), sep = "\\s", convert = TRUE) %>%
      mutate(user_url      = str_c("https://twitter.com/", screen_name, sep = ""),
             popup_content = str_c("<b><a href='", user_url, "'>", screen_name, "</a></b>", 
                                   "<br/>", "<br/>", text)) %>%
      select(screen_name, popup_content, source, place_full_name, lon, lat) %>%
      # Create map
      leaflet() %>%
      addTiles() %>%  
      setView(-81.5, 27.6, zoom = 5) %>%
      addMarkers(lng = ~lon, lat = ~lat, popup = ~popup_content)
    
  }) 
  
  output$fla_users <- renderDataTable({
    
    fla_tweets_data() %>%
      filter(!is.na(coordinates)) %>%
      select(screen_name)
    
  })
  
  # Panel 3: Trending Topics --------------------------------------------------
  
  usa_topics_data <- reactive({
    # For manual refreshing
    input$refresh
    
    usa_topics <- get_trends("United States", token = twitter_token) 
  })
  
  loc1_topics_data <- reactive({
    # For manual refreshing
    input$refresh
    
    loc1_topics <- get_trends(woeid = input$city_1, token = twitter_token) 
  })
  
  loc2_topics_data <- reactive({
    # For manual refreshing
    input$refresh
    
    loc2_topics <- get_trends(woeid = input$city_2, token = twitter_token) 
  })
  
  # USA Trending Topics
  output$usa_topics  <- renderDataTable({
    usa_topics_data() %>%
      select(trend, tweet_volume, place) %>%
      slice(1:10)
  })
  
  # City 1 Trending Topics
  output$loc1_topics <- renderDataTable({
    loc1_topics_data() %>% 
      select(trend, tweet_volume, place) %>% 
      slice(1:10)
  })
  
  # City 2 Trending Topics
  output$loc2_topics <- renderDataTable({
    loc2_topics_data() %>% 
      select(trend, tweet_volume, place) %>% 
      slice(1:10)
  })
  

}