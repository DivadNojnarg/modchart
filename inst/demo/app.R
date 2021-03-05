library(shiny)
library(modchart)
library(shinydashboard)
library(shinydashboardPlus)
library(modgetxl)
app<- shinyApp(
  ui= shinyUI(
    shinydashboardPlus::dashboardPage(
      skin='purple',
      header = shinydashboardPlus::dashboardHeader(title = 'Charts Demo'),
      sidebar=shinydashboardPlus::dashboardSidebar(sidebarMenuOutput('sidemenu'), minified = FALSE),
      body=dashboardBody(uiOutput('mainbody'))
    )
  ),
  server=shinyServer(function(input, output, session) {
    sink(file=stderr())
    
    options(shiny.maxRequestSize=1*1024^2) # 1MB
    
    output$xl<- renderUI({
      getxlUI('server')
    })
    xl<- callModule(getxl, 'server')
    
    output$charts<- renderUI({	
      if(length(xl$sheets) > 0) {
        title<- xl$sheets[1]
        if(title == 'mtcars' | title == 'airpass2')
          ndim<- 2
        else
          ndim<- 1
        nseries<- 1
        g<- xl2g(xl, ndim=ndim, nseries=nseries)
        callModule(chart, 'server', g)
        chartUI('server', g)
      }
    })
    output$sidemenu<- renderMenu({
      m1<- menuItem( "Upload Excel", menuSubItem("Excel", tabName="xltab"))
      m2<- menuItem( "Create Chart", menuSubItem("Chart", tabName="charttab"))
      sidebarMenu(m1,m2)
    })
    
    output$mainbody<- renderUI({
      t1<- list(); t1[[1]]<- tabItem(tabName="xltab", uiOutput("xl"))
      t2<- list(); t2[[1]]<- tabItem(tabName="charttab", uiOutput("charts"))
      do.call(tabItems, c(t1,t2))
    })
  })
)