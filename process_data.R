rm(list = ls())

library("httr")
library("tidyverse")

load("raw_dataset.RData")

length(raw_dataset)
names(raw_dataset)

raw_obj <- map(raw_dataset, httr::content)

obj <- raw_obj[["iter_1"]]
length(obj)
names(obj)
table(sapply(obj[["data"]], length))
which(sapply(obj[["data"]], length) == 3)
obj[["data"]][[15]]
which(sapply(obj[["data"]], length) == 4)
obj[["data"]][[1]]
which(sapply(obj[["data"]], length) == 5)
obj[["data"]][[2]]

setdiff(names(obj[["data"]][[1]]), names(obj[["data"]][[15]]))

table(sapply(obj[["includes"]], length))
names(obj[["includes"]])
table(sapply(obj[["includes"]][["tweets"]], length))
which(sapply(obj[["includes"]][["tweets"]], length) == 3)
obj[["includes"]][["tweets"]][[9]]

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
df_data <- obj[["data"]] %>% 
	{tibble(tweet_id         = map_chr(., "id"),
			text             = map_chr(., "text"),
			author_id        = map_chr(., "author_id"),
			tweet_type       = map_chr(., f_get_tweet_type),
			ref_tweet_id     = map_chr(., f_get_ref_tweet_id))}


# If I only need the text and the id, then that I can get like this:
df_includes <- obj[["includes"]][["tweets"]] %>% 
	{tibble(ref_tweet_id     = map_chr(., "id"),
			ref_author_id    = map_chr(., "author_id"),
			ref_tweet_text   = map_chr(., "text"))}
