rm(list=ls())

library("httr")
library("jsonlite")
library("tidyverse")
# add any other packages you might need to use

################################################
################################################
#
# test if you can connect to the API
#
################################################
################################################

# if you have correctly set your bearer token as an environment variable, 
# this retrieved the value of the token and assigns it to "bearer_token"
bearer_token <- Sys.getenv("BEARER_TOKEN")
# if you didn't manage to create the environment variable, then copy paste the 
# token below and comment out the line
# bearer_token <- "CopyPasteYourTokenHere"

# the authorization header is composed of the text Bearer + space + the token
headers <- c(Authorization = paste0('Bearer ', bearer_token))

# f_aux_functions.R is in the same directory as collect_data.R, which is the
# same as the working directory
# f_aux_functions.R contains two functions that you can use to test the token
# source("f_aux_functions.R") brings these in the current workspace 
source("f_aux_functions.R")
# you should now see f_test_API and f_test_token_API in the Environment pane
# type ?source in the console to learn more

f_test_API(use_header = headers)
remove(bearer_token)

my_header <- NULL
my_header[["header"]] <- headers
remove(headers)

# if you want to use the test functions, you need to uncomment the two lines above
# you can also take a look at examples/example_collect_all_tweets_from_one_user.R 
#		for another way of testing if you can connect to the API

################################################
################################################
#
# Does the bearer token allow you to collect data?
# if "Yes" -> continue
# else -> fix the error(s)
#
################################################
################################################

################################################
# Step 4: get account id
################################################

# collect the user_id for this handle
handle <- 'Ana_Martinovici'
url_handle <- paste0('https://api.twitter.com/2/users/by?usernames=', handle)
response <-	httr::GET(url = url_handle,
					  config = httr::add_headers(.headers = my_header[["header"]]))
# always check the HTTP response before doing anything else
httr::status_code(response)
# if 200 (Success), then continue.
# else, fix the issues first

# convert the output to text and then to a data frame
obj <- httr::content(response, as = "text")
df_obj <- jsonlite::fromJSON(obj, flatten = TRUE) %>% as.data.frame
print(df_obj)
# data.id is the user_id I need
user_id <- df_obj[["data.id"]]


url_handle <- paste0('https://api.twitter.com/2/users/', user_id, "/tweets")
# by default, the number of tweets retrieved per request is 10
# you can ask for more tweets (check the documentation for exact info)
params <- list(max_results = '20',
			   tweet.fields = "author_id,in_reply_to_user_id",
			   expansions = "referenced_tweets.id")
response <-	httr::GET(url = url_handle,
					  config = httr::add_headers(.headers = my_header[["header"]]),
					  query = params)
httr::status_code(response)

obj <- httr::content(response)



