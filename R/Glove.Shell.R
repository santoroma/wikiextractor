library(tidyverse)
library(quanteda)
library(jsonlite)
library(text2vec)
load("data/wiki_processed.RData")
wiki <- wiki %>% select(text) %>% unlist(use.names = FALSE)
tokens <- space_tokenizer(wiki)
it <- itoken_parallel(tokens)
rm(wiki)
#rm(tokens)
vocab <- create_vocabulary(it)
vocab <- prune_vocabulary(vocab, term_count_min = 5L,
                          doc_proportion_max = .3,
                          doc_count_min = 5L,
                          vocab_term_max = 2.e4)
# Use our filtered vocabulary
vectorizer <- vocab_vectorizer(vocab)
# use window of 5 for context words
#save.image("Before_tcm.RData")
tcm <- create_tcm(it, vectorizer, skip_grams_window = 5L)
####
glove_model <- GloVe$new(rank = 50, x_max = 10, learning_rate = .05)
word_vectors_main <- glove_model$fit_transform(tcm, n_iter = 100)
word_vectors_context <- glove_model$components
word_vectors <- word_vectors_main + t(word_vectors_context)
save(word_vectors, file = "word_vectors.RData")


cos_sim <- function(word_vectors, word, n_element = 5 ){
  word_coords <- word_vectors[word,]
  cc_ss <- sim2(as.matrix(word_vectors) , 
                y = as.matrix(word_coords) %>% t, 
                method = "cosine", norm = "l2")
  head(sort(cc_ss[,1], decreasing = TRUE), n_element)
}

cos_sim(word_vectors, "sicurezza")
word <- word_vectors["re",] - word_vectors["maschio",] +
  word_vectors["femmina",]


