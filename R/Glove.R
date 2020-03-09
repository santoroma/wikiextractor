library(tidyverse)
library(quanteda)
library(jsonlite)
library(text2vec)

wiki <- stream_in(file("test/Dump_Text.xml")) %>% as_tibble()

text_clean.f <- function(text){
  text <- text %>% xml2::read_html() %>% rvest::html_text()
  Stop <- c(rcorpora::corpora(glue::glue("words/stopwords/it"))$stopWords,
            stopwords::stopwords(language = "it"),
            stopwords::stopwords(language = "it", source = "stopwords-iso"),
            letters,"&","è","é","e'","ciò","cio'","perciò","percio'",
            "però","pero'","può","puo'","ahime'","ahimè","ahimé",
            "cioe'","cioè","cioé","citta'","città","così","cosi'","ivi",
            "dovrà","dovra'","gia'","già","la'","là","perchè","perche'","perché",
            "piu'","più","sara'","in", "sarà","della","dello","del","dell","il","lo","la", "che",
            "non","ha", "hanno", "i", "gli", "le", "uno", "una", "degli", "nel", "nello",
            "negli", '\"', "Section", "BULLET", "Collegamenti", "esterni") %>%
    unique() %>% char_tolower()
  text <- text %>% str_replace_all("[#_?]+|@[@]+", "") %>%
    str_replace_all("['’]", " ") %>% str_replace_all("-\n", "") %>% char_tolower() %>%
    quanteda::tokens(remove_url = TRUE, remove_punct = TRUE, remove_symbols = TRUE,
                     remove_separators = TRUE, split_hyphens = TRUE, remove_numbers = TRUE)
  text <- tokens_remove(text, Stop)
  
  
}

wiki <- wiki %>% 
  mutate(text = map_chr(text,
                        .f = )
wiki <- wiki %>% select(text) %>% unlist(use.names = FALSE)
tokens <- space_tokenizer(wiki)
it <- itoken_parallel(tokens)
vocab <- create_vocabulary(it)
vocab <- prune_vocabulary(vocab, term_count_min = 5L)
# Use our filtered vocabulary
vectorizer <- vocab_vectorizer(vocab)
# use window of 5 for context words
tcm <- create_tcm(it, vectorizer, skip_grams_window = 5L)
glove = GlobalVectors$new(rank = 50, x_max = 10)
glove$fit(tcm, n_iter = 20)
