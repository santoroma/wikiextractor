library(tidyverse)
library(quanteda)
library(jsonlite)
library(text2vec)

wiki <- stream_in(file("data/Dump_Text.xml")) %>% as_tibble()
quanteda_options(threads = 6)
text_clean.f <- function(text){
  pp <- try(text %>% xml2::read_html() %>% rvest::html_text(), silent = TRUE)
  if (!class(pp) == "try-error") {
    text <- pp
    rm(pp)
  }
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
                     remove_separators = TRUE, remove_hyphens = TRUE, remove_numbers = TRUE)
  text <- tokens_remove(text, Stop)
  text <- text %>% stringi::stri_c(collapse = " ")
  return(text)
}

wiki <- wiki %>% 
  mutate(text = map_chr(text,
                        .f = text_clean.f))
save(wiki, file = "wiki_processed.RData")
load("data/wiki_processed.RData")
#wiki <- corpus(wiki,docid_field = "id", text_field = "text")


wiki <- wiki %>% select(text) %>% unlist(use.names = FALSE)
tokens <- space_tokenizer(wiki)
it <- itoken_parallel(tokens)
rm(wiki)
#rm(tokens)
vocab <- create_vocabulary(it)
# save(vocab,file = "data/vocab.RData")
# load("data/vocab.RData")
vocab <- prune_vocabulary(vocab, term_count_min = 5L,
                          doc_proportion_max = .3,
                          doc_count_min = 5L,
                          vocab_term_max = 2.e4)
#save(vocab,file = "data/vocab_pruned.RData")
# Use our filtered vocabulary
vectorizer <- vocab_vectorizer(vocab)
# use window of 5 for context words
#save.image("Before_tcm.RData")
tcm <- create_tcm(it, vectorizer, skip_grams_window = 5L)
###quanteda approach
# load("data/wiki_processed.RData")
# 
# save(wiki, file = "data/wiki_as_corpus.RData")
# wiki <- fcm(wiki, 
#             context = "window", 
#             count = "frequency", 
#             window = 5L
#             )

glove = GlobalVectors$new(rank = 50, x_max = 10)
glove$fit(tcm, n_iter = 20)
