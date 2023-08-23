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

bps2022 <- bps2022 %>% 
  filter(SCHOOL != "BPS Business Service" & 
           SCHOOL != "School Support & Tranformation" &
           SCHOOL != "BPS Summer School Program" &
           SCHOOL != "BPS Athletics" &
           SCHOOL != "BPS Transportation" &
           SCHOOL != "BPS Boston School Committee" &
           SCHOOL != "BPS Office Of Budget Mgmt" & 
           SCHOOL != "BPS Welcome Services" & 
           SCHOOL != "BPS Long Term Leave" &
           SCHOOL != "BPS Facility Management" &
           SCHOOL != "BPS School Safety Service" &
           SCHOOL != "BPS Capital Planning Unit" &
           SCHOOL != "BPS Equity" &
           SCHOOL != "BPS Health and Wellness" &
           SCHOOL != "BPS Counseling & Intervtn Ct" &
           SCHOOL != "BPS Counseling Service" &
           SCHOOL != "BPS Human Resource Team" &
           SCHOOL != "BPS High School Renewal" &
           SCHOOL != "BPS Substitute Teachers/Nurs") #removing since not a school

#finding NA's
colSums(is.na(bps2022))
bps2022[apply(is.na(bps2022), 1, any), ]


bps2022 <- na.omit(bps2022, cols = "REGULAR")

#-----


teachers2022 <- bps2022 %>% 
  filter(TITLE == "Teacher")

#average teacher earnings for each school

teach_averages <- teachers2022 %>% 
  group_by(SCHOOL) %>% 
  summarise('Base' = mean(REGULAR, na.rm = TRUE), 
            'Retro' = mean(RETRO),
            'Overtime' = mean(OVERTIME),
            'Injured' = mean(INJURED),
            'Other' = mean(OTHER),
            mean_gross = mean(TOTAL_GROSS)
  ) %>% 
  arrange(mean_gross)



teach_averages$SCHOOL <- factor(teach_averages$SCHOOL, levels = teach_averages$SCHOOL)

teach_averages_long <- teach_averages %>% 
  select(-mean_gross) %>% 
  pivot_longer(cols = -SCHOOL, names_to = "earnings_type", values_to = "average_amount")

teach_averages_long$earnings_type <- factor(teach_averages_long$earnings_type, 
                                            levels = c("Other", "Injured", "Retro", "Overtime", "Base")) #ordering stacks

#------ plotting stacked bar graph

y_lim_max <- max(teach_averages$mean_gross) * 1.1
x_label_margin <- 10

bps2022_teach_bar <- teach_averages_long %>% 
  ggplot(aes(x = SCHOOL, y = average_amount, fill = earnings_type)) +
  geom_bar(stat = "identity", position = "stack") +
  annotate("text", 
           x = teach_averages$SCHOOL, 
           y = teach_averages$mean_gross, 
           label = round(teach_averages$mean_gross, 2), 
           hjust = -0.45, size = 1, color = "black") +
  coord_flip(ylim = c(0, y_lim_max)) +
  labs(title = "Boston Public Schools Teacher Average Gross Earnings in 2022",
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

bps2022_teach_bar

ggsave(filename = "bps2022_teach_bar.png", plot = bps2022_teach_bar, width = 13, height = 7, dpi = 600)

#---------teacher histogram


bps2022_teach_hist <- teachers2022 %>% 
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
  geom_text(aes(x = median(TOTAL_GROSS) + 15000, y = 700, label = paste("Median:", sprintf("%.2f", median(TOTAL_GROSS)))), color = "#2E45B8") +
  labs(title = "Boston Public Schools Teacher Gross Earnings in 2022 Distribution",
       x = "Dollars($)",
       y = "Count",
       caption = paste("Source: data.boston.gov", "u/BostonConnor11", sep = "\n")) +
  theme_economist() +
  theme(axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0)),
        axis.title.x = element_text(margin = margin(t = 20, r = 0, b = 0, l = 0)),
        plot.title.position = "plot",
        plot.title = element_text(margin = margin(b = 30))) 

bps2022_teach_hist

ggsave(filename = "bps2022_teach_hist.png", plot = bps2022_teach_hist, width = 13, height = 7, dpi = 600)

#-------- teacher map

teachers2022$POSTAL[teachers2022$POSTAL == '02199'] <- '02129'

#average earnings for each postal code
postal_averages <- teachers2022 %>% 
  group_by(POSTAL) %>% 
  summarise(count = n(),
            mean_gross = mean(TOTAL_GROSS)
  ) %>% 
  arrange(mean_gross)

library(sf)

postal_sf <- sf::st_read("ZIP_Codes.geojson") %>% 
  rename(POSTAL = ZIP5)

postal_df <- na.omit(left_join(postal_sf, postal_averages, by = "POSTAL"))

teachers2022 %>% filter(POSTAL == 02199)

#average earnings for each postal code
teach_postal_averages <- teachers2022 %>% 
  group_by(POSTAL) %>% 
  summarise(count = n(),
            mean_gross = mean(TOTAL_GROSS)
  ) %>% 
  arrange(mean_gross)

library(sf)

teach_postal_df <- na.omit(left_join(postal_sf, teach_postal_averages, by = "POSTAL"))


postal_teach_choro <- ggplot() +
  geom_sf(data = teach_postal_df, aes(fill = mean_gross), color = "black") +
  geom_sf_text(data = teach_postal_df, aes(label = paste(teach_postal_df$POSTAL)), size = 2, color = "gray") +
  scale_fill_viridis_c(name = 'Average Gross Earnings ($)', option = 'viridis', 
                       guide = guide_colorbar(label.theme = element_text(size = 8), barwidth = unit(4, "inches")),
                       breaks = c(60000, 80000, 100000),
                       labels = c("60k", "80k", "100k")) +
  labs(title = "Average BPS Teacher Total Gross Earnings in 2022 by Zip Code",
       caption = paste("Source: data.boston.gov", "u/BostonConnor11", sep = "\n")) +
  theme_economist() +
  theme(axis.text = element_blank(),
        axis.title = element_blank(),
        axis.ticks = element_blank(),
        panel.grid = element_blank())

postal_teach_choro

ggsave(filename = "bps2022_teach_postal_map.png", plot = postal_teach_choro, width = 15, height = 12, dpi = 600)


#----- top 20 highest earning

teach_top_20 <- teach_averages_long %>% 
  group_by(SCHOOL) %>% 
  summarize(total_earning = sum(average_amount)) %>%
  arrange(-total_earning) %>% 
  head(20) %>% 
  pull(SCHOOL)

teach_top_20_averages <- teach_averages %>% 
  filter(SCHOOL %in% teach_top_20)

teach_top_20_averages_long <- teach_averages_long %>% 
  filter(SCHOOL %in% teach_top_20)

bps2022_teach_top_20 <- teach_top_20_averages_long %>% 
  ggplot(aes(x = SCHOOL, y = average_amount, fill = earnings_type)) +
  geom_bar(stat = "identity", position = "stack") +
  annotate("text", 
           x = teach_top_20_averages$SCHOOL, 
           y = teach_top_20_averages$mean_gross, 
           label = round(teach_top_20_averages$mean_gross, 2), 
           hjust = -0.45, size = 3.5, color = "black") +
  coord_flip(ylim = c(0, y_lim_max)) +
  labs(title = "Top 20 BPS Teacher Average Gross Earnings in 2022",
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

bps2022_teach_top_20

ggsave(filename = "bps2022_teach_top_20.png", plot = bps2022_teach_top_20, width = 13, height = 7, dpi = 300)

#------ bottom 20 earnings


teach_bottom_20 <- teach_averages_long %>% 
  group_by(SCHOOL) %>% 
  summarize(total_earning = sum(average_amount)) %>%
  arrange(total_earning) %>% 
  head(20) %>% 
  pull(SCHOOL)

teach_bottom_20_averages <- teach_averages %>% 
  filter(SCHOOL %in% teach_bottom_20)

teach_bottom_20_averages_long <- teach_averages_long %>% 
  filter(SCHOOL %in% teach_bottom_20)

bps2022_teach_bottom_20 <- teach_bottom_20_averages_long %>% 
  ggplot(aes(x = SCHOOL, y = average_amount, fill = earnings_type)) +
  geom_bar(stat = "identity", position = "stack") +
  annotate("text", 
           x = teach_bottom_20_averages$SCHOOL, 
           y = teach_bottom_20_averages$mean_gross, 
           label = round(teach_bottom_20_averages$mean_gross, 2), 
           hjust = -0.45, size = 3.5, color = "black") +
  coord_flip(ylim = c(0, y_lim_max)) +
  labs(title = "Bottom 20 BPS Teacher Average Gross Earnings in 2022",
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

bps2022_teach_bottom_20

ggsave(filename = "bps2022_teach_bottom_20.png", plot = bps2022_teach_bottom_20, width = 13, height = 7, dpi = 300)

#------- Box Plot by School Type------  

teachers2022 <- teachers2022 %>% 
  mutate(SCHOOL_TYPE = case_when(
    grepl("elementary", SCHOOL, ignore.case = TRUE) ~ "Elementary",
    grepl("K-8", SCHOOL, ignore.case = TRUE) ~ "K-8",
    grepl("Middle", SCHOOL, ignore.case = TRUE) ~ "Middle",
    grepl("Academy", SCHOOL, ignore.case = TRUE) ~ "Academy",
    grepl("High|hi", SCHOOL, ignore.case = TRUE) ~ "High",
    TRUE ~ "Other"
  ))

teachers2022$SCHOOL_TYPE <- factor(teachers2022$SCHOOL_TYPE, levels = c("Other", "Academy", "Elementary", "K-8", "Middle","High"))

bps2022_teach_box <- teachers2022 %>% 
  ggplot(aes(x = SCHOOL_TYPE, y = TOTAL_GROSS, fill = SCHOOL_TYPE)) +
  geom_violin(width = 1) +
  geom_boxplot(width = 0.2, color = "#F6423C") +
  stat_summary(fun.y = mean, geom = "errorbar", aes(ymax = ..y.., ymin = ..y..), width = 0.2, linetype = "dashed", color = "#FB9851") +
  annotate("text", x = 1, y = mean(teachers2022$TOTAL_GROSS), label = "Mean", vjust = -0.5, color = "#FB9851", size = 2.5) + # adjust x and y accordingly
  annotate("text", x = 1, y = median(teachers2022$TOTAL_GROSS), label = "Median", vjust = -1, color = "#F6423C", size = 2.5) + # adjust x and y accordingly
  labs(title = "BPS Teacher Average Gross Earnings in 2022 Distribution by School Type",
       x = "School",
       y = "Dollars ($)",
       fill = "Earning Type",
       caption = paste("Source: data.boston.gov", "u/BostonConnor11", sep = "\n")) +
  theme_economist() +
  scale_fill_economist() +
  theme(axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0)))

bps2022_teach_box

ggsave(filename = "bps2022_teach_box.png", plot = bps2022_teach_box, width = 13, height = 7, dpi = 600)



#--------------Stacked bar by school type

type_averages <- teachers2022 %>% 
  group_by(SCHOOL_TYPE) %>% 
  summarise('Base' = mean(REGULAR, na.rm = TRUE), 
            'Retro' = mean(RETRO),
            'Overtime' = mean(OVERTIME),
            'Injured' = mean(INJURED),
            'Other' = mean(OTHER),
            mean_gross = mean(TOTAL_GROSS)
  ) %>% 
  arrange(mean_gross)

#converting department column into a factor so the stacked bar plot arranges it by mean_gross instead of alphabetically
type_averages$SCHOOL_TYPE <- factor(type_averages$SCHOOL_TYPE, levels = type_averages$SCHOOL_TYPE)

#creating a long format for easier stacking of the pay categories
type_averages_long <- type_averages %>% 
  select(-mean_gross) %>% 
  pivot_longer(cols = -SCHOOL_TYPE, names_to = "earnings_type", values_to = "average_amount")

type_averages_long$earnings_type <- factor(type_averages_long$earnings_type, 
                                           levels = c("Other", "Injured", "Retro", "Overtime", "Base")) #ordering stacks


y_lim_max <- max(type_averages$mean_gross) * 1.1
x_label_margin <- 10

bps2022_type_bar <- type_averages_long %>% 
  ggplot(aes(x = SCHOOL_TYPE, y = average_amount, fill = earnings_type)) +
  geom_bar(stat = "identity", position = "stack") +
  annotate("text", 
           x = type_averages$SCHOOL_TYPE, 
           y = type_averages$mean_gross, 
           label = round(type_averages$mean_gross, 2), 
           hjust = -0.45, size = 3.5, color = "black") +
  coord_flip(ylim = c(0, y_lim_max)) +
  labs(title = "BPS Average Gross Earnings in 2022 by School Type",
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
        axis.text.y = element_text(margin = margin(t = 0, r = -30, b = 0, l = 0)),
        axis.title.x = element_text(margin = margin(t = 20, r = 0, b = 0, l = 0)))

bps2022_type_bar

ggsave(filename = "bps2022_type_bar.png", plot = bps2022_type_bar, width = 13, height = 7, dpi = 600)
