#install.packages('rsconnect')
#rsconnect::setAccountInfo(name="wafiesa", token="B6646A0E748F020D72D099EAAE6D4A6C", secret="w5mKyBsq5j+3QoFqbBiwuZ7dLbgB6wn9upQBk1lG")
#library(rsconnect)
#rsconnect::deployApp()

library(shiny)
library(shinydashboard)
library(tidyverse)
library(forecast)
library(zoo)
library(DT)
library(readxl)
library(httr)
library(plotly)

# Load the dataset
url <- "https://github.com/wafiesa/Financial_Approval_Dashboard/blob/2ac61a8bf7d6b1c6dc81e8ead50337fe0fbcf917/1.12_Approvals_by_Sector.xlsx?raw=true"
temp_file <- tempfile(fileext = ".xlsx")
GET(url, write_disk(temp_file, overwrite = FALSE))

data <- read_excel(temp_file, skip = 5)

# Rename the columns
data <- data %>%
  rename(
    Year = `End of Period`,
    Month = `...2`
  )

# Remove specific text prefixes in "Sector" column
data <- data %>%
  mutate(
    Sector = gsub("Bank-bank perdagangan / |Bank-bank Islam / |Bank-bank pelaburan / |Institusi kewangan pembangunan / |Jumlah / ", "", Sector)
  )

# Function to fill Year based on Month progression
fill_year_based_on_month <- function(data) {
  current_year <- NA  # Placeholder for tracking the year
  for (i in 1:nrow(data)) {
    if (!is.na(data$Year[i])) {
      # Update the current year when it's available in the dataset
      current_year <- data$Year[i]
    } else if (!is.na(data$Month[i])) {
      # Use the current year for the missing Year value
      if (data$Month[i] == 1 && !is.na(current_year)) {
        # Increment year if Month resets to 1
        current_year <- current_year + 1
      }
      data$Year[i] <- current_year
    }
  }
  return(data)
}

# Apply the function to your dataset
data <- fill_year_based_on_month(data)

# Define a function to propagate Year and Month values 4 rows upward
fill_values_above <- function(data) {
  for (i in seq_len(nrow(data))) {
    # Check if the current row meets the condition for "Total"
    if (data$Sector[i] == "Total" &&
        !is.na(as.numeric(data$Month[i])) &&
        !is.na(as.numeric(data$Year[i]))) {
      
      # Propagate Year and Month 4 rows above
      for (j in 1:4) {
        if (i - j > 0) {  # Ensure not going out of bounds
          data$Year[i - j] <- data$Year[i]
          data$Month[i - j] <- data$Month[i]
        }
      }
    }
  }
  return(data)
}

# Apply the function to your dataset
data <- fill_values_above(data)

# Remove rows with NaN values
data <- data %>%
  filter(complete.cases(.))  # Retain only rows without NaN values

# Change sector col name to Financial Institution 
data<- data %>% rename('Financial_Institution' = Sector)

data <- data %>%
  mutate(
    Date = as.Date(paste(Year, Month, "01", sep = "-")) # Create valid dates
  )

data<- data %>% select(-c("Year", "Month"))
data<- data %>% select("Date", everything())
data<- data %>% mutate(across(where(is.numeric), ~ round(.x, digits=2)))

# Define UI
ui <- dashboardPage(
  dashboardHeader(title = "FINANCING APPROVALS FOR SMALL AND MEDIUM ENTERPRISES (SMEs)"),
  dashboardSidebar(
    tags$style(HTML("
      .main-sidebar {
      background-color: #00203f !important;
    }
    .sidebar-menu > li > a {
      color: White !important; /* White text */
      font-weight: bold !important; 
      font-size: 15px !important;
    }
    .sidebar-menu > li > a:hover {
     background-color: #004080 !important; 
    }
    .sidebar-menu > li.active > a {
      background-color: #FFA836 !important; 
      color: white !important;
      font-size: 15px !important;
    }
    ")),
    
      sidebarMenu(
      menuItem("About The Dashboard", tabName = "explanation", icon = icon("info-circle")),
      menuItem("Data Overview", tabName = "data_overview", icon = icon("table")),
      menuItem("Visualisation", tabName = "visualisation", icon = icon("chart-line")),
      menuItem("Forecasting", tabName = "forecasting", icon = icon("chart-bar"))
    ),
    
    # CHANGED: Fixed inputs for Financial Institution, Date Range and Forecast Model
    selectInput("financial_institution", "Select Financial Institution:", 
                choices = unique(data$Financial_Institution), 
                selected = "Commercial Banks"), 

    sliderInput("date_range", "Select Date Range:",
                min = min(data$Date, na.rm = TRUE),
                max = max(data$Date, na.rm = TRUE),
                value = c(min(data$Date, na.rm = TRUE), max(data$Date, na.rm = TRUE)),
                timeFormat = "%Y-%m",
                animate = animationOptions(interval= 1500, loop=TRUE))
  ),
  
  dashboardBody(
    tags$style(HTML("
    .main-header .navbar {
    background-color: #1F2833 !important; 
    text-align: center; /* Center the header */
    display: flex; 
    justify-content: center; /* make the content center & horizontal */
    align-items: center; /* make the content center & vertical */
  }
  .main-header .logo {
    background-color: #1F2833 !important; 
    color: #FFFFFF !important; 
    font-weight: bold;
    font-size: 18px !important; 
    width: 100%; /* Use full width for centering */
    text-align: center; /* text post */
    padding: 0 !important; 
    
    }
    .content-wrapper {
    background-color: #E0E1DD !important; 
    }
    
    table.dataTable {
      border-collapse: collapse !important;
      border: 2px solid #0D1B2A;
    }
    table.dataTable th, table.dataTable td {
      border: 1px solid #D4A373 !important;
      padding: 8px;
      text-align: center;
    }
    ")),
    
    tabItems(
      # Tab 1: About The Dashboard
      tabItem(tabName = "explanation",
              h2("About The Dashboard"),
              p("The Central Bank of Malaysia (Bank Negara Malaysia, BNM) champions financial inclusion initiatives with the vision of building an inclusive financial system."),
              p("Financial inclusion plays a vital role in promoting shared prosperity and economic development by empowering individuals and small businesses to actively engage in the financial ecosystem."),
              p("One of the many significant contributions supporting the growth of Small and Medium Enterprises (SMEs) over the years is the availability of access to financing."),
              p("This dashboard provides an overview of financing approvals for SMEs from the following Financial Institutions (FIs):"),
              tags$ul(
                tags$li("Commercial Banks"),
                tags$li("Islamic Banks"),
                tags$li("Investment Banks"),
                tags$li("Development Financial Institutions")
              ),
              p("The dataset from BNM Financial Inclusion, named 1.12_Approvals_by_Sector which can be obtained from https://www.bnm.gov.my/financial-inclusion-data-for-malaysia contains financing approvals across 16 economic sectors as listed below:"),
              tags$ul(
                tags$li("Agriculture, Forestry and Fishing"),
                tags$li("Mining and Quarrying"),
                tags$li("Manufacturing"),
                tags$li("Electricity, Gas, Steam and Air Conditioning Supply"),
                tags$li("Water Supply, Sewerage, Waste Management and Remediation Activities"),
                tags$li("Construction"),
                tags$li("Wholesale and Retail Trade"),
                tags$li("Accommodation and Food Service Activities"),
                tags$li("Transportation & Storage"),
                tags$li("Information & Communication"),
                tags$li("Financial and Insurance/Takaful Activities"),
                tags$li("Real Estate Activities"),
                tags$li("Professional, Scientific and Technical Activities"),
                tags$li("Administrative and Support Service Activities"),
                tags$li("Education, Health and Others"),
                tags$li("Other Sectors")
              ),
              p("Before exploring the dashboard, it is important to note the following:"),
              tags$ul(
                tags$li("Data Overview Tab displays an overview of the dataset, including details of economic sectors and financial institutions. It uses the 1.12_Approvals_by_Sector dataset from BNM. Several data cleaning steps have been applied to make the raw dataset compatible with this dashboard. Future users can use the same dataset (1.12_Approvals_by_Sector) without additional preparation."),
                tags$li("Visualisation Tab produces time series plots from the dataset, allowing users to select an economic sector and financial institution. It provides insights into trends, seasonality and random fluctuations within the time series data."),
                tags$li("Forecasting Tab displays forecast plots for a selected economic sector and financial institution using the Auto ARIMA model. Users can enhance the model by adjusting the forecasting period ahead. The forecast plot automatically updates when this setting is modified.")
              ),
              p("The time series dashboard is a valuable tool for observing trends in financing approvals by financial institutions across economic sectors. Insights derived from the dashboard can guide financial institutions in aligning resources to support BNM’s financial inclusion vision. Additionally, it is hoped that this dashboard will disseminate financing information for SMEs across various economic sectors and encourage financial institutions to provide financing solutions for underserved sectors in the near future."),
              p("Disclaimer: The developer of this dashboard is not responsible for collecting the dataset, as it primarily visualises time series data derived from BNM's dataset. It should also be noted that BNM, as a monetary regulator, has the right to revise and expand the dataset. The developer is not liable for any losses resulting from the use of this dashboard.")
      ),
      
      # Tab 2: Data Overview
      tabItem(tabName = "data_overview",
              h2("Data Overview"),
              tags$h3("Financing Approvals by Economic Sectors", style = "text-align: center; margin-bottom: 10px;"),
              tags$h4("Currency in RM Million", style = "text-align: center; margin-bottom: 20px; color: gray;"),
              DT::dataTableOutput("data_table")
      ),
      
      # Tab 3: Visualisation
      tabItem(tabName = "visualisation",
              h2("Visualisation"),
              selectInput("item", "Select Economic Sector:", 
                          choices = names(data)[3:18], 
                          selected = "Agriculture, Forestry and Fishing"),
              plotlyOutput("time_series_plot")
      ),
      
      # Tab 4: Forecasting
      tabItem(tabName = "forecasting",
              h2("Forecasting"),
              selectInput("item", "Select Economic Sector:", 
                          choices = names(data)[3:18], 
                          selected = "Agriculture, Forestry and Fishing"),
              
              # Add conditional panel for user input
              conditionalPanel(
                condition = "$('ul.sidebar-menu li.active a').text().trim() === 'Forecasting'",
                sliderInput("horizon", "Set Period (to forecast ahead):", value = 12, min = 1, max=12)),
              plotlyOutput("forecast_plot")
      )
    )
  )
)

# Define server logic
server <- function(input, output, session) {
  
  # Reactive: Filtered data based on inputs
  filtered_data <- reactive({
    req(input$date_range, input$financial_institution) # Validate inputs
    data %>%
      filter(
        Financial_Institution == input$financial_institution,
        Date >= input$date_range[1],
        Date <= input$date_range[2]
      )
  })
  
  # Data Table
  output$data_table <- DT::renderDataTable({
    filtered <- filtered_data()
    validate(
      need(nrow(filtered) > 0, "No data available for the selected financial institution and date range.")
    )
    DT::datatable(filtered, options = list(scrollX = TRUE, pageLength = 10, autoWidth = TRUE))
  })
  
  # Time-Series Plot
  output$time_series_plot <- renderPlotly({
    req(input$item)
    filtered <- filtered_data()
    validate(
      need(nrow(filtered) > 0, "No data available for visualisation.")
    )
    
    # Summarise the data for the selected item
    item_data <- filtered %>%
      group_by(Date) %>%
      summarise(Value = sum(get(input$item), na.rm = TRUE))
    
    plot_ly(item_data, x = ~Date, y = ~Value, type = 'scatter', mode = 'lines') %>%
      layout(
        title = paste("Financing Approvals in", input$item, "sector by", input$financial_institution),
        xaxis = list(title = "Year"),
        yaxis = list(title = "Approved Financing (in RM million)")
      )
  })
  
  # Forecast Plot
  output$forecast_plot <- renderPlotly({
    req(input$item, input$horizon)
    
    filtered <- filtered_data()
    
    validate(
      need(nrow(filtered) > 0, "Not enough data for forecasting.")
    )
    
    item_data <- filtered %>%
      group_by(Date) %>%
      summarise(Value = sum(get(input$item), na.rm = TRUE))
    
    ts_data <- ts(item_data$Value, start = c(year(min(item_data$Date)), month(min(item_data$Date))), frequency = 12)
    
    forecasted_values <- forecast(auto.arima(ts_data, seasonal = TRUE, stepwise = FALSE, approximation = FALSE), h = input$horizon)
    
    forecast_df <- data.frame(
      Date = seq(max(item_data$Date) + months(1), by = "month", length.out = input$horizon),
      Forecast = as.numeric(forecasted_values$mean),
      Lower80 = as.numeric(forecasted_values$lower[, 1]),  # 80% lower bound
      Upper80 = as.numeric(forecasted_values$upper[, 1]),  # 80% upper bound
      Lower95 = as.numeric(forecasted_values$lower[, 2]),  # 95% lower bound
      Upper95 = as.numeric(forecasted_values$upper[, 2])   # 95% upper bound
    )
    
    plot_ly() %>%
      add_lines(x = item_data$Date, y = item_data$Value, name = "Actual", line = list(color = "blue")) %>%
      add_lines(x = forecast_df$Date, y = forecast_df$Forecast, name = "Forecast", line = list(color = "orange")) %>%
      add_ribbons(x = forecast_df$Date, ymin = forecast_df$Lower95, ymax = forecast_df$Upper95,
                  name = "95% Confidence Interval", fillcolor = 'rgba(0,100,80,0.2)', line = list(color = "transparent")) %>%
      add_ribbons(x = forecast_df$Date, ymin = forecast_df$Lower80, ymax = forecast_df$Upper80,
                  name = "80% Confidence Interval", fillcolor = 'rgba(0,100,200,0.2)', line = list(color = "transparent")) %>%
      layout(
        title = paste("Forecasted Approvals for", input$item, "sector by", input$financial_institution),
        xaxis = list(title = "Year"),
        yaxis = list(title = "Forecasted Financing (in RM million)"),
        legend = list(orientation = "h", x = 0.1, y = -0.2)
      )
  }) 
  
} 

# Run the application 
shinyApp(ui = ui, server = server)
