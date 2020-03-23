load("../word_vectors.RData")
cos_sim <- function(word_vectors, word, cos_sim_min = .5){
  word_coords <- word_vectors[word,]
  cc_ss <- sim2(as.matrix(word_vectors) , 
                y = as.matrix(word_coords) %>% t, 
                method = "cosine", norm = "l2")
  cc_ss <- sort(cc_ss[,1], decreasing = TRUE)
  cc_ss[which(cc_ss >= .5)]
}
