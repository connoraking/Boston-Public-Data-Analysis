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


fire_stations <- sf::st_read("Fire_Departments.geojson")

#------------- map ----------

library(viridis)
library(ggthemes)


g_choro <- ggplot() +
  geom_sf(data = df_neigh, aes(fill = n), color = "black") +
  geom_sf_text(data = df_neigh, aes(label = paste(df_neigh$neighborhood, "\n", df_neigh$n)), size = 3.5, color = "#E3120B") +
  scale_fill_viridis_c(name = 'Fire Incidents', option = 'plasma', 
                       guide = guide_colorbar(label.theme = element_text(size = 8), barwidth = unit(4, "inches"))) +
  labs(title = "Count of Fire Incidents in each Boston neighborhood since 2014",
       caption = paste("Source: data.boston.gov", "github.com/connoraking", sep = "\n")) +
  theme_economist() +
  theme(axis.text = element_blank(),
        axis.title = element_blank(),
        axis.ticks = element_blank(),
        panel.grid = element_blank())#,
        #panel.background = element_rect(fill = "#E9EDF0"),
        #plot.background = element_rect(fill = "#76c0c1"))

g_choro

ggsave(filename = "incident_choro.png", plot = g_choro, width = 15, height = 12, dpi = 600)

station_choro <- ggplot() +
  geom_sf(data = df_neigh, aes(fill = n), color = "black") +
  geom_sf(data = fire_stations, color = "white", size = 3) + 
  geom_sf(data = fire_stations, color = "red", size = 2) + 
  scale_fill_viridis_c(name = 'Fire Incidents', option = 'plasma', 
                       guide = guide_colorbar(label.theme = element_text(size = 8), barwidth = unit(4, "inches"))) +
  scale_color_identity(name = "", guide = "legend", labels = "Fire Station") +
  labs(title = "Incidents since 2014 with Stations",
       caption = paste("Source: data.boston.gov", "github.com/connoraking", sep = "\n")) +
  theme_economist() +
  theme(axis.text = element_blank(),
        axis.title = element_blank(),
        axis.ticks = element_blank(),
        panel.grid = element_blank())#,
#panel.background = element_rect(fill = "#E9EDF0"),
#plot.background = element_rect(fill = "#76c0c1"))

station_choro

ggsave(filename = "incident_choro_station.png", plot = station_choro, width = 15, height = 12, dpi = 600)


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
             caption = paste("Source: data.boston.gov", "github.com/connoraking", sep = "\n")) +
        scale_x_continuous(breaks = 2014:2022, limits = c(2014, 2022)) +
        theme_economist() +
  theme(axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0)),
        axis.title.x = element_text(margin = margin(t = 20, r = 0, b = 0, l = 0))) 

p_year  
  
ggsave(filename = "incident_years.png", plot = p_year, width = 13, height = 7, dpi = 600)  


#-----month bar chart
month_counts <- df %>% 
  count(month = month(alarm_date))

b_month <- month_counts %>% 
  ggplot(aes(x = factor(month, levels = 1:12, labels = month.abb), y = n)) +
  geom_col(fill = "#C91D42") +
  geom_text(aes(label = n), vjust = -0.75, size =3) +
  geom_point(aes(y = n, group = 1), color = "#377EB8", size = 2) + 
  labs(
    title = "Monthly Fire Incident Frequency since 2014",
    x = "Month",
    y = "Count of Incidents",
    caption = paste("Source: data.boston.gov", "github.com/connoraking", sep = "\n")
  ) +
  theme_economist() +
  theme(axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0)),
        axis.title.x = element_text(margin = margin(t = 20, r = 0, b = 0, l = 0))) 


b_month

ggsave(filename = "incident_months.png", plot = b_month, width = 13, height = 7, dpi = 600)


#-----  hour line plot

hour_counts <- df %>% 
  group_by(hour = hour(alarm_time)) %>% 
  summarize(count = n())

hour_counts$diff_from_noon <- abs(hour_counts$hour - 12) #used to make color brighter around noon

h_line <- hour_counts %>% 
  ggplot(aes(x = hour, y = count, color = diff_from_noon)) +
  geom_line(size = 1.25) +
  geom_point(aes(color = diff_from_noon), size = 4) +
  scale_x_continuous(breaks = 0:23, labels = sprintf("%02d:00", 0:23)) +
  scale_color_gradient(low = "yellow", high = "blue", name = "Hour's proximity to noon") +
  labs(title = "Fire Incidents by Time of Day since 2014",
       x = "Hour of the Day",
       y = "Number of Incidents",
       caption = paste("Source: data.boston.gov", "github.com/connoraking", sep = "\n")
  ) +
  theme_economist() +
  theme(axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0)),
        axis.title.x = element_text(margin = margin(t = 20, r = 0, b = 0, l = 0))) 

h_line

ggsave(filename = "incident_hours.png", plot = h_line, width = 13, height = 7, dpi = 600)

#------incident word-cloud

library(ggwordcloud)

incident_count <- df %>% 
  group_by(incident_description) %>% 
  summarize(count = n(), prop_loss = mean(estimated_property_loss), content_loss = mean(estimated_content_loss), total_loss = mean(estimated_property_loss + estimated_content_loss))

w_plot <- incident_count %>% 
  ggplot(aes(label = incident_description, size = count, color = log(total_loss + 1))) +
  geom_text_wordcloud() +
  scale_size_area(max_size = 20) +
  scale_color_viridis_c(option = "plasma") +
  labs(subtitle = "Word size = incident frequency since 2014. Word color = avg. total $ loss (log scale).",
    caption = paste("Source: data.boston.gov", "u/BostonConnor11", sep = "\n")) +
  theme_economist() +
  theme(
    plot.margin = margin(t = 5, r = 5, b = 5, l = 5))#, # Reduce plot margins
#    panel.background = element_rect(fill = "#7ad2f6"),
 #   plot.background = element_rect(fill = "#7ad2f6"),
  #  panel.border = element_blank(),
   # axis.line = element_blank()
  #)

w_plot

ggsave(filename = "incident_word_cloud.png", plot = w_plot, width = 16, height = 8, dpi = 600)
  
total_incidents <- nrow(df)

zero_loss_incidents <- sum((df$estimated_property_loss + df$estimated_content_loss) == 0)

proportion_zero_loss <- zero_loss_incidents / total_incidents

#-------property type word cloud

property_count <- df %>% 
  filter(!is.na(property_description)) %>% 
  group_by(property_description) %>% 
  summarize(count = n(), prop_loss = mean(estimated_property_loss), content_loss = mean(estimated_content_loss), total_loss = mean(estimated_property_loss + estimated_content_loss))

pw_plot <- property_count %>% 
  ggplot(aes(label = property_description, size = count, color = log(total_loss + 1))) +
  geom_text_wordcloud() +
  scale_size_area(max_size = 20) +
  scale_color_viridis_c(option = "plasma") +
  labs(subtitle = "Word size = property description frequency since 2014. Word color = avg. total $ loss (log scale).",
       caption = paste("Source: data.boston.gov", "github.com/connoraking", sep = "\n")) +
  theme_economist() +
  theme(
    plot.margin = margin(t = 5, r = 5, b = 5, l = 5))#, # Reduce plot margins
    #panel.background = element_rect(fill = "#7ad2f6"),
    #plot.background = element_rect(fill = "#7ad2f6"))

pw_plot

ggsave(filename = "incident_prop_word_cloud.png", plot = pw_plot, width = 16, height = 8, dpi = 600)








  
  
  
  