library(tidyverse)

df <- read_csv("tmpzaibcv5b.csv")

library(sf)

#neighborhood boundaries
boston_sf <- sf::st_read("Boston_Neighborhoods.kml") %>% 
  rename(neighborhood = Name)
boston_sf$Description <- NULL

combined_neigh <- boston_sf %>% 
  filter(neighborhood %in% c('Allston', 'Brighton')) %>% 
  group_by(neighborhood = 'Allston-Brighton') %>% 
  summarize(geometry = st_union(geometry))


#since the fire dataset just has "Boston" as a neighborhood, I combined the nieghborhoods that I *THINK* make it up
combined_inner <- boston_sf %>% 
  filter(neighborhood %in% c(
    'Mission Hill', 'Longwood', 'Fenway', 'Back Bay', 'South End', 'Bay Village', 'Chinatown', 'Leather District', 'Downtown', 'South Boston Waterfront',
    'Beacon Hill', 'West End', 'North End'
  )) %>% 
  group_by(neighborhood = 'Inner Boston') %>% 
  summarize(geometry = st_union(geometry))

boston_sf_c <- rbind(boston_sf[!boston_sf$neighborhood %in% c('Allston', 'Brighton'), ], combined_neigh)
boston_sf_c <- rbind(boston_sf_c[!boston_sf$neighborhood %in% c(
  'Mission Hill', 'Longwood', 'Fenway', 'Back Bay', 'South End', 'Bay Village', 'Chinatown', 'Leather District', 'Downtown', 'South Boston Waterfront',
  'Beacon Hill', 'West End', 'North End'
), ], combined_inner)

#neighborhood means

neigh_counts <- df %>% 
  filter(!is.na(neighborhood)) %>% 
  count(neighborhood)

neigh_counts[neigh_counts$neighborhood == 'Boston', 'neighborhood'] <- 'Inner Boston'

df_neigh <- na.omit(left_join(boston_sf_c, neigh_counts, by = "neighborhood"))
#df_neigh <- df_neigh[df_neigh$neighborhood != 'Harbor Islands', ] #removing harbor islands as there are only 63 incidents and it's messing up the color scale


library(viridis)

g_choro <- ggplot() +
  geom_sf(data = df_neigh, aes(fill = n), color = NA) +
  geom_sf_text(data = df_neigh, aes(label = paste(df_neigh$neighborhood, "\n", df_neigh$n)), size = 2, color = "#E41A1C") +
  scale_fill_viridis_c(name = 'Fire Incidents', option = 'viridis') +
  labs(title = "Count of Fire Incidents in each Boston neighborhood since 2014",
       caption = paste("Source: data.boston.gov", "u/BostonConnor11", sep = "\n")) +
  theme_minimal() +
  theme(axis.text = element_blank(),
        axis.title = element_blank(),
        axis.ticks = element_blank(),
        panel.grid = element_blank(),
        legend.text = element_text(color = "#E41A1C"),
        legend.title = element_text(color = "#E41A1C"),
        plot.title = element_text(color = "#E41A1C"),
        plot.caption = element_text(color = "#E41A1C"))

g_choro

ggsave(filename = "incident_choro.png", plot = g_choro, width = 13, height = 7, dpi = 300)


#--------- year line plot

df$alarm_date <- ymd(df$alarm_date)


year_counts <- df %>% 
  count(year = year(alarm_date))
year_counts <- year_counts[year_counts$year != 2023, ]


library(ggthemes)
library(ggrepel)


p_year <-  ggplot(year_counts, aes(x = year, y = n)) +
        geom_line(size = 1.25, color = "#E41A1C") +
        geom_point(color = "#377EB8", size = 2.5) +
        geom_text_repel(aes(label = n), 
                        box.padding = 1.15, 
                        point.padding = 0.6, 
                        nudge_y = 2,
                        direction = "y",
                        segment.color = "transparent") +
        labs(title = "Count of Fire Incidents in Boston over the Years",
             y = "Count of Incidents",
             x = "Year",
             caption = paste("Source: data.boston.gov", "u/BostonConnor11", sep = "\n")) +
        scale_x_continuous(breaks = 2014:2022, limits = c(2014, 2022)) +
        theme_economist() +
  theme(axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0)),
        axis.title.x = element_text(margin = margin(t = 20, r = 0, b = 0, l = 0))) 

p_year  
  
ggsave(filename = "incident_years.png", plot = p_year, width = 13, height = 7, dpi = 300)  


#-----month bar chart
month_counts <- df %>% 
  count(month = month(alarm_date))

b_month <- month_counts %>% 
  ggplot(aes(x = factor(month, levels = 1:12, labels = month.abb), y = n)) +
  geom_col(fill = "#1DC9A4") +
  theme_economist() +


b_month


#------incident word-cloud

library(ggwordcloud)



incident_count <- df %>% 
  group_by(incident_description) %>% 
  summarize(count = n(), prop_loss = mean(estimated_property_loss), content_loss = mean(estimated_content_loss))

w_plot <- incident_count %>% 
  ggplot(aes(label = incident_description, size = count, color = log(prop_loss))) +
  geom_text_wordcloud() +
  scale_color_viridis_c(name = "Average Property Loss ($)", option = "inferno") +
  labs(subtitle = "Word size = incident frequency. Word color = avg. property loss (log scale).",
    caption = paste("Source: data.boston.gov", "u/BostonConnor11", sep = "\n")) +
  theme_minimal() 

w_plot

ggsave(filename = "incident_word_cloud.png", plot = w_plot, width = 13, height = 7, dpi = 300)












  
  
  
  