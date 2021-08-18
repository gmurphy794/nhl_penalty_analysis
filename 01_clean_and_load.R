#Load and Clean Data

#load libraries
library(tidyverse)
library(dplyr)


#Loading in Data
game_data <- read.csv("./data/game.csv")
Viewgame_officials <- read.csv('./data/game_officials.csv')
game_penalties <- read.csv('./data/game_penalties.csv')
game_plays <- read.csv('./data/game_plays.csv')
team_info <- read.csv('./data/team_info.csv')
game_plays_players <- read.csv('./data/game_plays_players.csv')
player_info <- read.csv('./data/player_info.csv')


#Data Exploration
View(game_data)
View(game_officials)
View(game_penalties)
View(team_info)

###Combining Penalty and Team Data

#Grabbing penalty plays only
penalty_data <- game_plays %>% 
  filter(event == 'Penalty') %>% 
  select(-secondaryType, -description) %>% 
  mutate(play_id = as.factor(play_id))

#Grabbing Regular Season Games only
game_types <- game_data %>% 
  select(game_id, type) %>% 
  filter(type == 'R') %>% 
  distinct()

penalty_data <- penalty_data %>% 
  inner_join(game_types, by = 'game_id')


#Removing unecessary Team Info columns
team_info <- team_info %>% 
  select(team_id, abbreviation) %>% 
  distinct()

#Joining Penalty Data with Team info
penalty_data <- penalty_data %>% 
  left_join(team_info, by = c('team_id_for' = 'team_id')) %>% 
  rename(team_against = abbreviation) %>% 
  left_join(team_info, by = c('team_id_against' = 'team_id')) %>% 
  rename(team_for = abbreviation)

#Joining Penalty Data with Game Penalties
penalty_data <- penalty_data %>% 
  left_join(game_penalties, by = 'play_id')


#Joining Penalty Data with Officials Data
penalty_data <- penalty_data %>% 
  left_join(game_officials, by = 'game_id')

###Combining Penalty and Player info

#Removing unnecessary player columns
player_info <- player_info %>% 
  select(player_id, firstName, lastName)

#Joining Game play players with player ids 
game_plays_players <- game_plays_players %>% 
  left_join(player_info, by = 'player_id') %>% 
  mutate(play_id = as.character(play_id)) %>% 
  select(-game_id)


#Joining with Penalty Data
penalty_data <- penalty_data %>% 
  left_join(game_plays_players, by = 'play_id')

#Adding season info
seasons <- game_data %>% 
  filter(type == 'R') %>% 
  select(game_id,season) %>% 
  distinct()
penalty_data <- penalty_data %>% 
  left_join(seasons, by = 'game_id')



#Getting Home-Away information
home_teams <- game_data %>% 
  select(game_id, home_team_id) %>% 
  left_join(team_info, by = c('home_team_id' = 'team_id'))%>% 
  rename(home_team = abbreviation) %>% 
  select(-home_team_id)

#Joining with penalty data
penalty_data <- penalty_data %>% 
  left_join(home_teams, by = 'game_id')

#Removing duplicate rows
penalty_data <- penalty_data %>% distinct()

###Saving to R data file
save(penalty_data, file = './data/penalty_data.Rdata')





