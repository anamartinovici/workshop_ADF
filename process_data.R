rm(list = ls())

library("httr")
library("tidyverse")

load("raw_dataset.RData")

length(raw_dataset)
names(raw_dataset)

raw_obj <- map(raw_dataset, httr::content)

raw_obj_data <- map(raw_obj, "data")
map(raw_obj_data, length)
raw_obj_data <- purrr::flatten(raw_obj_data)

# from obj_data, I need: author_id, id, type_of_tweet, info about the referenced tweet
f_get_tweet_type <- function(input_list) {
	if(is.null(input_list[["referenced_tweets"]])) {
		# you can change the label to use for a tweet that is neither a quote or a retweet
		return("original_tweet")
	} else {
		return(input_list[["referenced_tweets"]][[1]][["type"]])	
	}
}

f_get_ref_tweet_id <- function(input_list) {
	if(is.null(input_list[["referenced_tweets"]])) {
		# you can change the label to use for a tweet that is neither a quote or a retweet
		return("original_tweet")
	} else {
		return(input_list[["referenced_tweets"]][[1]][["id"]])	
	}
}

# rearrange the data
df_data <- raw_obj_data %>% 
	{tibble(tweet_id         = map_chr(., "id"),
			text             = map_chr(., "text"),
			author_id        = map_chr(., "author_id"),
			tweet_type       = map_chr(., f_get_tweet_type),
			ref_tweet_id     = map_chr(., f_get_ref_tweet_id))}


raw_obj_includes <- map(raw_obj, "includes")
map(raw_obj_includes, length)
raw_obj_includes <- purrr::flatten(raw_obj_includes)
map(raw_obj_includes, length)
raw_obj_includes <- purrr::flatten(raw_obj_includes)


# If I only need the text and the id, then that I can get like this:
df_includes <- raw_obj_includes %>% 
	{tibble(ref_tweet_id     = map_chr(., "id"),
			ref_author_id    = map_chr(., "author_id"),
			ref_tweet_text   = map_chr(., "text"))}
