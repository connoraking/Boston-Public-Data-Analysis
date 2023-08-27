library(tidyverse)
library(ggthemes)
#source: https://data.boston.gov/dataset/employee-earnings-report
earnings2022 <- read_csv("finalconsolidatedcy22earnings_feb2023.xlsx-sheet1.csv")

sort(unique(earnings2022$DEPARTMENT_NAME))

#creating dataset with just the schools
bps2022 <- earnings2022 %>% 
  filter(grepl('Boston Collaborative|BPS|K-8|School|Academy|UP', DEPARTMENT_NAME)) %>% 
  rename(TOTAL_GROSS = 'TOTAL_ GROSS') %>% 
  rename(SCHOOL = 'DEPARTMENT_NAME')

bps2022 <- bps2022 %>% 
  select(-QUINN_EDUCATION, -DETAIL)

#replacing NA's with 0
cols_for_zero <- c('RETRO', 'OVERTIME', 'OTHER', 'INJURED')
bps2022[cols_for_zero][is.na(bps2022[cols_for_zero])] <- 0 

# bps2022 <- bps2022 %>% 
#   filter(SCHOOL != "BPS Business Service" & 
#          SCHOOL != "School Support & Tranformation" &
#           SCHOOL != "BPS Summer School Program" &
#            SCHOOL != "BPS Athletics" &
#            SCHOOL != "BPS Transportation" &
#            SCHOOL != "BPS Boston School Committee" &
#            SCHOOL != "BPS Office Of Budget Mgmt" & 
#            SCHOOL != "BPS Welcome Services" & 
#            SCHOOL != "BPS Long Term Leave" &
#            SCHOOL != "BPS Facility Management" &
#            SCHOOL != "BPS School Safety Service" &
#            SCHOOL != "BPS Capital Planning Unit" &
#            SCHOOL != "BPS Equity" &
#            SCHOOL != "BPS Health and Wellness" &
#            SCHOOL != "BPS Counseling & Intervtn Ct" &
#            SCHOOL != "BPS Counseling Service" &
#            SCHOOL != "BPS Human Resource Team" &
#            SCHOOL != "BPS High School Renewal" &
#            SCHOOL != "BPS Substitute Teachers/Nurs") #removing since not a school

#finding NA's
colSums(is.na(bps2022))
bps2022[apply(is.na(bps2022), 1, any), ]


bps2022 <- na.omit(bps2022, cols = "REGULAR")

#average earnings for each school
averages <- bps2022 %>% 
  group_by(SCHOOL) %>% 
  summarise('Base' = mean(REGULAR, na.rm = TRUE), 
            'Retro' = mean(RETRO),
            'Overtime' = mean(OVERTIME),
            'Injured' = mean(INJURED),
            'Other' = mean(OTHER),
            mean_gross = mean(TOTAL_GROSS)
  ) %>% 
  arrange(mean_gross)

#converting department column into a factor so the stacked bar plot arranges it by mean_gross instead of alphabetically
averages$SCHOOL <- factor(averages$SCHOOL, levels = averages$SCHOOL)

#creating a long format for easier stacking of the pay categories
averages_long <- averages %>% 
  select(-mean_gross) %>% 
  pivot_longer(cols = -SCHOOL, names_to = "earnings_type", values_to = "average_amount")

averages_long$earnings_type <- factor(averages_long$earnings_type, 
                                      levels = c("Other", "Injured", "Retro", "Overtime", "Base")) #ordering stacks

#------ plotting stacked bar graph

y_lim_max <- max(averages$mean_gross) * 1.1
x_label_margin <- 10

bps2022_bar_plot <- averages_long %>% 
  ggplot(aes(x = SCHOOL, y = average_amount, fill = earnings_type)) +
  geom_bar(stat = "identity", position = "stack") +
  annotate("text", 
           x = averages$SCHOOL, 
           y = averages$mean_gross, 
           label = round(averages$mean_gross, 2), 
           hjust = -0.45, size = 1, color = "black") +
  coord_flip(ylim = c(0, y_lim_max)) +
  labs(title = "Boston Public Schools Average Gross Earnings in 2022",
       x = "School",
       y = "Dollars ($)",
       fill = "Earning Type",
       caption = paste("Source: data.boston.gov", "u/BostonConnor11", sep = "\n")) +
  theme_economist(horizontal = FALSE) +
  scale_fill_economist() +
  scale_y_continuous(breaks = c(0, 50000, 100000),
                     labels = c("0", "50,000", "100,000")) +   # This line adds specific breaks
  guides(fill = guide_legend(reverse = TRUE)) + #reverses legend so the colors match the order of the colors of the bars
  theme(axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0)),
        axis.text.y = element_text(size = 4, margin = margin(t = 0, r = -30, b = 0, l = 0)))
        
bps2022_bar_plot

ggsave(filename = "bps2022_bar_plot.png", plot = bps2022_bar_plot, width = 13, height = 7, dpi = 300)

#----- histogram

bps2022_hist <- bps2022 %>% 
  ggplot(aes(x = TOTAL_GROSS)) +
  geom_histogram(color = "black", fill = "#76c0c1") +
  geom_vline(aes(xintercept = mean(TOTAL_GROSS)),
             color = "#E3120B", 
             linetype = "dashed",
             size = 1.25) +
  geom_text(aes(x = mean(TOTAL_GROSS) - 15000, y = 700, label = paste("Mean:", sprintf("%.2f", mean(TOTAL_GROSS)))), color = "#E3120B") +
  geom_vline(aes(xintercept = median(TOTAL_GROSS)),
             color = "#2E45B8", 
             linetype = "dashed",
             size = 1.25) +
  geom_text(aes(x = median(TOTAL_GROSS) + 15000, y = 800, label = paste("Median:", sprintf("%.2f", median(TOTAL_GROSS)))), color = "#2E45B8") +
  labs(title = "Boston Public Schools Gross Earnings in 2022 Distribution",
       x = "Dollars($)",
       y = "Count",
       caption = paste("Source: data.boston.gov", "u/BostonConnor11", sep = "\n")) +
  theme_economist() +
  theme(axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0)),
        axis.title.x = element_text(margin = margin(t = 20, r = 0, b = 0, l = 0)),
        plot.title.position = "plot",
        plot.title = element_text(margin = margin(b = 30))) 


bps2022_hist

ggsave(filename = "bps2022_hist.png", plot = bps2022_hist, width = 13, height = 7, dpi = 300)

#----- top 20 highest earning

top_20 <- averages_long %>% 
  group_by(SCHOOL) %>% 
  summarize(total_earning = sum(average_amount)) %>%
  arrange(-total_earning) %>% 
  head(20) %>% 
  pull(SCHOOL)

top_20_averages <- averages %>% 
  filter(SCHOOL %in% top_20)

top_20_averages_long <- averages_long %>% 
  filter(SCHOOL %in% top_20)
  
bps2022_top_20 <- top_20_averages_long %>% 
  ggplot(aes(x = SCHOOL, y = average_amount, fill = earnings_type)) +
  geom_bar(stat = "identity", position = "stack") +
  annotate("text", 
           x = top_20_averages$SCHOOL, 
           y = top_20_averages$mean_gross, 
           label = round(top_20_averages$mean_gross, 2), 
           hjust = -0.45, size = 3.5, color = "black") +
  coord_flip(ylim = c(0, y_lim_max)) +
  labs(title = "Top 20 Boston Public Schools Average Gross Earnings in 2022",
       x = "School",
       y = "Dollars ($)",
       fill = "Earning Type",
       caption = paste("Source: data.boston.gov", "u/BostonConnor11", sep = "\n")) +
  theme_economist(horizontal = FALSE) +
  scale_fill_economist() +
  scale_y_continuous(breaks = c(0, 50000, 100000),
                     labels = c("0", "50,000", "100,000")) +   # This line adds specific breaks
  guides(fill = guide_legend(reverse = TRUE)) + #reverses legend so the colors match the order of the colors of the bars
  theme(axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0)),
        axis.text.y = element_text(margin = margin(t = 0, r = -20, b = 0, l = 0)))

bps2022_top_20

ggsave(filename = "bps2022_top_20.png", plot = bps2022_top_20, width = 13, height = 7, dpi = 300)

#------ bottom 20 earnings


bottom_20 <- averages_long %>% 
  group_by(SCHOOL) %>% 
  summarize(total_earning = sum(average_amount)) %>%
  arrange(total_earning) %>% 
  head(20) %>% 
  pull(SCHOOL)

bottom_20_averages <- averages %>% 
  filter(SCHOOL %in% bottom_20)

bottom_20_averages_long <- averages_long %>% 
  filter(SCHOOL %in% bottom_20)

bps2022_bottom_20 <- bottom_20_averages_long %>% 
  ggplot(aes(x = SCHOOL, y = average_amount, fill = earnings_type)) +
  geom_bar(stat = "identity", position = "stack") +
  annotate("text", 
           x = bottom_20_averages$SCHOOL, 
           y = bottom_20_averages$mean_gross, 
           label = round(bottom_20_averages$mean_gross, 2), 
           hjust = -0.45, size = 3.5, color = "black") +
  coord_flip(ylim = c(0, y_lim_max)) +
  labs(title = "Bottom 20 Boston Public Schools Average Gross Earnings in 2022",
       x = "School",
       y = "Dollars ($)",
       fill = "Earning Type",
       caption = paste("Source: data.boston.gov", "u/BostonConnor11", sep = "\n")) +
  theme_economist(horizontal = FALSE) +
  scale_fill_economist() +
  scale_y_continuous(breaks = c(0, 50000, 100000),
                     labels = c("0", "50,000", "100,000")) +   # This line adds specific breaks
  guides(fill = guide_legend(reverse = TRUE)) + #reverses legend so the colors match the order of the colors of the bars
  theme(axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0)),
        axis.text.y = element_text(margin = margin(t = 0, r = -20, b = 0, l = 0)))

bps2022_bottom_20

ggsave(filename = "bps2022_bottom_20.png", plot = bps2022_bottom_20, width = 13, height = 7, dpi = 300)


#------- postal map

unique(bps2022$POSTAL)

#average earnings for each postal code
postal_averages <- bps2022 %>% 
  group_by(POSTAL) %>% 
  summarise(count = n(),
            mean_gross = mean(TOTAL_GROSS)
  ) %>% 
  arrange(mean_gross)

library(sf)

postal_sf <- sf::st_read("ZIP_Codes.geojson") %>% 
  rename(POSTAL = ZIP5)

postal_df <- na.omit(left_join(postal_sf, postal_averages, by = "POSTAL"))


postal_choro <- ggplot() +
  geom_sf(data = postal_df, aes(fill = mean_gross), color = "black") +
  geom_sf_text(data = postal_df, aes(label = paste(postal_df$POSTAL)), size = 2, color = "gray") +
  scale_fill_viridis_c(name = 'Average Gross Earnings ($)', option = 'viridis', 
                       guide = guide_colorbar(label.theme = element_text(size = 8), barwidth = unit(4, "inches")),
                       breaks = c(60000, 80000, 100000),
                       labels = c("60k", "80k", "100k")) +
  labs(title = "Average Total Gross Earnings in 2022 by Zip Code",
       caption = paste("Source: data.boston.gov", "u/BostonConnor11", sep = "\n")) +
  theme_economist() +
  theme(axis.text = element_blank(),
        axis.title = element_blank(),
        axis.ticks = element_blank(),
        panel.grid = element_blank())

postal_choro

ggsave(filename = "bps2022_postal_map.png", plot = postal_choro, width = 15, height = 12, dpi = 600)
