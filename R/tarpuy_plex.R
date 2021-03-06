#' Fieldbook plan information
#'
#' Information for build a plan for an experiment (PLEX)
#'
#' @param data Data with the fieldbook information.
#' @param idea How the idea was born.
#' @param goal The main goal of the project.
#' @param hypothesis What are the expected results.
#' @param rationale Based in which evidence is planned the experiment.
#' @param objectives The objectives of the project.
#' @param plan General description of the project (M & M).
#' @param institutions Institutions involved in the project.
#' @param researchers Persons involved in the project.
#' @param manager Persons responsible of the collection of the data.
#' @param location Location of the project.
#' @param altitude Altitude of the experiment (m.a.s.l).
#' @param georeferencing Georeferencing information.
#' @param environment Environment of the experiment (greenhouse, lab, etc).
#' @param start The date of the start of the experiments.
#' @param end The date of the end of the experiments.
#' @param album link with the photos of the project.
#' @param github link with the github repository.
#' @param about Short description of the project.
#' @param fieldbook Name or ID for the fieldbook/project.
#' @param nfactor Number of factors for the design.
#' @param design Type of design.
#' @param rep Number of replication.
#' @param serie Number of digits in the plots.
#' @param seed Seed for the randomization.
#'
#' @details
#'
#' Provide the information available.
#'
#' @return data frame or list of arguments:
#'
#'   \enumerate{ \item info \item variables \item design \item logbook \item
#'   timetable \item budget }
#'
#' @importFrom dplyr mutate
#' @importFrom tibble tribble deframe
#' @importFrom stringr word str_to_upper
#' 
#' @export
#'
#' 

tarpuy_plex <- function(data = NULL
                          , idea = NULL
                          , goal = NULL
                          , hypothesis = NULL
                          , rationale = NULL
                          , objectives = NULL
                          , plan = NULL
                          , institutions = NULL
                          , researchers = NULL
                          , manager = NULL
                          , location = NULL
                          , altitude = NULL
                          , georeferencing = NULL
                          , environment = NULL
                          , start = NA
                          , end = NA
                          , about = NULL
                          , fieldbook = NULL
                          , album = NULL
                          , github = NULL
                          , nfactor = 2
                          , design = "rcbd"
                          , rep = 3
                          , serie = 2
                          , seed = 0
                         ) {

  # idea <- goal <- hypothesis <-  rationale <- objectives <-  plan <- NA
  # institutions <- researchers <- manager <- location <- altitude <- NA
  # georeferencing <- environment <- start <- end <- album <- github <- NA
  # fieldbook <- NULL
  # nfactor = 1
  # design = "crd"
  # rep = 2
  # serie = 2
  # seed = 0

  PLEX <- INFORMATION <- DAI <- NULL

# arguments ---------------------------------------------------------------

  # start <- "2020-08-15" ; end <- "2020-12-03"

  start  <-  start %>% as.Date(format = "%Y-%m-%d")
  end  <-  end %>% as.Date(format = "%Y-%m-%d")
  
  if (is.na(start)) {
    
    start  <-  Sys.Date() %>% as.Date(format = "%Y-%m-%d")
    
  } 
  
  if (is.na(end) | end == Sys.Date() ) {

    end  <-  start + 90 
    
    } 

# fieldbook name ----------------------------------------------------------
  
  # fieldbook <- NULL
  # about <- "Sëed germinatión 1/2"
  # location <- "Lä Molína, Lima, Perú"

  if( is.null(fieldbook) &
      !is.null(location) & !is.null(start[1]) & !is.null(about) ) {
    
    fbname <- paste(strsplit(location, ",") %>% unlist() %>% pluck(1)
                    , as.character(start[1])
                    , about
                    , sep = " "
                    ) %>%
      # iconv(., "latin1", "ASCII//TRANSLIT") %>% 
      stringi::stri_trans_general("Latin-ASCII") %>%
      stringr::str_to_upper()
    
    qrcode <- paste(strsplit(location, ",") %>% unlist() %>% pluck(1)
                    , as.character(start[1])
                    , sep = "_"
                    ) %>%
      # iconv(., "latin1", "ASCII//TRANSLIT") %>% 
      stringi::stri_trans_general("Latin-ASCII") %>%
      stringr::str_to_upper() %>% 
      gsub("[[:space:]]", "-", .)
      
    
  } else {
    
    fbname <- fieldbook
    
    qrcode <- fieldbook %>%
      # iconv(., "latin1", "ASCII//TRANSLIT") %>% 
      stringi::stri_trans_general("Latin-ASCII") %>%
      stringr::str_to_upper() %>% 
      gsub("[[:space:]]", "-", .)
    
  }
    

# plex -----------------------------------------------------------------------

if ( is.null(data) ) {

  plex <-  c(IDEA = idea
             , GOAL = goal
             , HYPOTHESIS = hypothesis
             , RATIONALE = rationale
             , OBJECTIVES = objectives
             , PLAN = plan
             , INSTITUTIONS = institutions
             , RESEARCHERS = researchers
             , MANAGER = manager
             , LOCATION = location
             , ALTITUDE = altitude
             , GEOREFERENCING = georeferencing
             , ENVIRONMENT = environment
             , "START EXPERIMENT" = as.character.Date(start)
             , "END EXPERIMENT" = as.character.Date(end)
             , ABOUT = about
             , "FIELDBOOK NAME" = fbname
             , GITHUB = github
             , ALBUM = album
             ) %>%
    enframe() %>%
    rename('PLEX' = .data$name, 'INFORMATION' = .data$value)
  
  } else if ( !is.null(data) ) { # for import to the app?

  plex <- data %>%
    mutate(across(.data$PLEX, tolower)) %>%
    mutate(PLEX = word(PLEX, 1)) %>%
    deframe()
}

# variables ---------------------------------------------------------------

var_list <- tibble(variable = rep(NA, 5)
                   , siglas = rep(NA, 5) # abbreviation
                   , evaluation = rep(NA, 5) # evaluation, eval dap dat
                   , sampling = rep(NA, 5) # sampling sample subplot muestra
                   , units = rep(NA, 5)
                   , description = rep(NA, 5)
                   ) %>%
  rename('{siglas}' = .data$siglas
         , '{evaluation}' = .data$evaluation
         , '{sampling}' = .data$sampling)

# design ------------------------------------------------------------------

factors <- c(paste0("factor", 1:nfactor))

dsg_info <-  c(nfactors = nfactor
              , type = design
              , rep = rep
              , serie = serie
              , seed = seed
              , qr = qrcode
              ) %>%
  enframe() %>%
  rename('{arguments}' = .data$name, '{values}' = .data$value)

  dsg_info[,factors] <- NA

# timetable ---------------------------------------------------------------

finish <- end - start

first_col <- c("Activities (DAI)"
               , "Material Preparation"
               , rep(NA, 5)
               , "Evaluation"
               , rep(NA, 5)
               , "Data processing"
               ) %>%
  enframe(value = "Dates") %>% select(!.data$name)

ttable <- c(DAI = seq.int(from = -15, to = finish, by = 5)) %>%
  enframe() %>%
  mutate(date =  format( .data$value + start, "%d/%b")) %>%
  select(date, DAI = .data$value) %>%
  pivot_wider(names_from = date, values_from = DAI)

timetable <- merge( first_col
                    , ttable
                    , by = 0
                    , all = TRUE
                    )  %>%
  mutate(across(.data$Row.names, as.numeric)) %>%
  arrange(.data$Row.names) %>%
  select(!.data$Row.names)

# logbook -----------------------------------------------------------------

desc <- "Day After Initiation (DAI) of experiment."

logbook <- tibble(Date = c(rep(NA, 3), as.character.Date(start), rep(NA, 3))
               , DAI = c(rep(NA, 3), 0, rep(NA, 3))
               , Activity = c(rep(NA, 3), "Init experiment", rep(NA, 3))
               , Description = c(rep(NA, 3), desc, rep(NA, 3))
               )

# budget ------------------------------------------------------------------

budget <- tibble("Material/Service" = rep(NA, 5)
                 , Unit = rep(NA, 5)
                 , Price = rep(NA, 5)
                 , Quantity = rep(NA, 5)
                 , Total = rep(NA, 5)
                 , Description = rep(NA, 5)
                 )

# result ------------------------------------------------------------------

list(plex = plex
     , design = dsg_info
     , variables = var_list
     , logbook = logbook
     , timetable = timetable
     , budget = budget
     )

}
