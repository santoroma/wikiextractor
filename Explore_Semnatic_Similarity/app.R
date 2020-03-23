#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Explor Semantic Similarity (IT based on Wikipedia-IT"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            textInput("word",
                      "Inserisci una parola (tutto minuscolo)",
                      value = "ambizione")
            #,
 #           textInput("word_minus",
   #                   "Inserisci parola da togliere",
  #                    value = NULL),
 #           textInput("word_plus",
  #                    "Inserisci parola da aggiungere",
 #                     value = NULL),
            # numericInput("cos_sim_min",
            #              "Valore minimo per la cosine similarity tra 0 e 1",
            #              0.5),
            # actionButton("go","Run")
            # 
        ),

        # Show a plot of the generated distribution
        mainPanel(
            tableOutput("sim_words")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    
    
    output$sim_words <- renderTable({
        input$go
        word <- word_vectors[input$word]
 #       if (!is.null(input$word_minus)) word <- word - word_vectors[input$word_minus]
 #       if (!is.null(input$word_plus)) word <- word + word_vectors[input$word_plus]
        data_out <- cos_sim(word_vectors, input$word)
        data_out <- tibble("word" = names(data_out), 
                           "cosin_similarity" = data_out)
        data_out
        # data_out %>% as.data.frame()
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
