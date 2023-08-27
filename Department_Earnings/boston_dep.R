library(tidyverse)
library(ggthemes)
#source: https://data.boston.gov/dataset/employee-earnings-report
earnings2022 <- read_csv("finalconsolidatedcy22earnings_feb2023.xlsx-sheet1.csv")

#finding the distinct departments

distinct_deps <- earnings2022 %>% 
  distinct(DEPARTMENT_NAME) %>% 
  filter(grepl('Department', DEPARTMENT_NAME))

df <- earnings2022 %>% 
  filter(grepl('Department', DEPARTMENT_NAME)) %>% 
  rename(TOTAL_GROSS = 'TOTAL_ GROSS')

cols_for_zero <- c('RETRO', 'OVERTIME', 'OTHER', 'DETAIL', 'INJURED', 'QUINN_EDUCATION')
df[cols_for_zero][is.na(df[cols_for_zero])] <- 0

averages <- df %>% 
  group_by(DEPARTMENT_NAME) %>% 
  summarise('Base' = mean(REGULAR, na.rm = TRUE), 
            'Detail' = mean(DETAIL), 
            'Retro' = mean(RETRO),
            'Overtime' = mean(OVERTIME),
            'Injured' = mean(INJURED),
            'Education Incentive' = mean(QUINN_EDUCATION),
            'Other' = mean(OTHER),
            mean_gross = mean(TOTAL_GROSS)
            ) %>% 
  arrange(mean_gross)

#converting department column into a factor so the stacked bar plot arranges it by mean_gross instead of alphabetically
averages$DEPARTMENT_NAME <- factor(averages$DEPARTMENT_NAME, levels = averages$DEPARTMENT_NAME)

#creating a long format for easier stacking of the pay categories
averages_long <- averages %>% 
  select(-mean_gross) %>% 
  pivot_longer(cols = -DEPARTMENT_NAME, names_to = "earnings_type", values_to = "average_amount")

averages_long$earnings_type <- factor(averages_long$earnings_type, 
                                      levels = c("Other", "Education Incentive", "Injured", "Retro", "Detail", "Overtime", "Base")) #ordering stacks

y_lim_max <- max(averages$mean_gross) * 1.1
x_label_margin <- 10

stacked_2022_plot <- averages_long %>% 
  ggplot(aes(x = DEPARTMENT_NAME, y = average_amount, fill = earnings_type)) +
  geom_bar(stat = "identity", position = "stack") +
  annotate("text", 
           x = averages$DEPARTMENT_NAME, 
           y = averages$mean_gross, 
           label = round(averages$mean_gross, 2), 
           hjust = -0.45, size = 3.5, color = "black") +
  coord_flip(ylim = c(0, y_lim_max)) +
  labs(title = "Boston Departments Average Earnings in 2022",
      x = "Department",
      y = "Dollars ($)",
      fill = "Earning Type",
      caption = paste("Source: data.boston.gov", "github.com/connoraking", sep = "\n")) +
  theme_economist(horizontal = FALSE) +
  scale_fill_economist() +
  theme(axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0)))
 
stacked_2022_plot

ggsave(filename = "stacked_2022_earnings.png", plot = stacked_2022_plot, width = 13, height = 7, dpi = 300)
#------now creating line chart based off of previous years

earnings2011 <- read_csv("employee-earnings-report-2011.csv") %>% 
  rename(DEPARTMENT_NAME = 'Department Name') %>% 
  filter(grepl('Department', DEPARTMENT_NAME)) %>% 
  mutate(`Total Earnings` = as.numeric(gsub("[,$]", "", `Total Earnings`))) #removing dollar sign

average2011 <- earnings2011 %>% 
  group_by(DEPARTMENT_NAME) %>% 
  summarise(mean_gross = mean(`Total Earnings`))


earnings2012 <- read_csv("employee-earnings-report-2012.csv") %>% 
  rename(DEPARTMENT_NAME = 'DEPARTMENT') %>% 
  filter(grepl('Department', DEPARTMENT_NAME)) %>% 
  mutate(`Total Earnings` = as.numeric(gsub("[,$]", "", `TOTAL EARNINGS`))) #removing dollar sign

average2012 <- earnings2012 %>% 
  group_by(DEPARTMENT_NAME) %>% 
  summarise (mean_gross = mean(`Total Earnings`))


earnings2013 <- read_csv("employee-earnings-report-2013.csv") %>% 
  rename(DEPARTMENT_NAME = 'DEPARTMENT') %>% 
  filter(grepl('Department', DEPARTMENT_NAME)) %>% 
  mutate(`Total Earnings` = as.numeric(gsub("[,$]", "", `TOTAL EARNINGS`)))

average2013 <- earnings2013 %>% 
  group_by(DEPARTMENT_NAME) %>% 
  summarise (mean_gross = mean(`Total Earnings`))


earnings2014 <- read_csv("employee-earnings-report-2014.csv") %>% 
  rename(DEPARTMENT_NAME = `DEPARTMENT NAME`) %>% 
  filter(grepl('Department', DEPARTMENT_NAME)) %>% 
  mutate(`Total Earnings` = as.numeric(gsub("[,$]", "", `TOTAL EARNINGS`)))

average2014 <- earnings2014 %>% 
  group_by(DEPARTMENT_NAME) %>% 
  summarise (mean_gross = mean(`Total Earnings`))


earnings2015 <- read_csv("employee-earnings-report-2015.csv") %>% 
  filter(grepl('Department', DEPARTMENT_NAME)) %>% 
  mutate(`Total Earnings` = as.numeric(gsub("[,$]", "", `TOTAL EARNINGS`)))

average2015 <- earnings2015 %>% 
  group_by(DEPARTMENT_NAME) %>% 
  summarise (mean_gross = mean(`Total Earnings`))


earnings2016 <- read_csv("employee-earnings-report-2016.csv") %>% 
  filter(grepl('Department', DEPARTMENT_NAME)) %>% 
  mutate(`Total Earnings` = as.numeric(gsub("[,$]", "", `TOTAL EARNINGS`)))

average2016 <- earnings2016 %>% 
  group_by(DEPARTMENT_NAME) %>% 
  summarise (mean_gross = mean(`Total Earnings`))


earnings2017 <- read_csv("employee-earnings-report-2017.csv") %>% 
  rename(DEPARTMENT_NAME = `DEPARTMENT NAME`) %>% 
  filter(grepl('Department', DEPARTMENT_NAME)) %>% 
  mutate(`Total Earnings` = as.numeric(gsub("[,$]", "", `TOTAL EARNINGS`)))

average2017 <- earnings2017 %>% 
  group_by(DEPARTMENT_NAME) %>% 
  summarise (mean_gross = mean(`Total Earnings`))


earnings2018 <- read_csv("employeeearningscy18full.csv") %>% 
  filter(grepl('Department', DEPARTMENT_NAME))

average2018 <- earnings2018 %>% 
  group_by(DEPARTMENT_NAME) %>% 
  summarise (mean_gross = mean(`TOTAL EARNINGS`))


earnings2019 <- read_csv("allemployeescy2019_feb19_20final-all.csv") %>% 
  filter(grepl('Department', DEPARTMENT_NAME))

average2019 <- earnings2019 %>% 
  group_by(DEPARTMENT_NAME) %>% 
  summarise (mean_gross = mean(`TOTAL EARNINGS`))


earnings2020 <- read_csv("city-of-boston-calendar-year-2020-earnings.csv") %>% 
  filter(grepl('Department', DEPARTMENT_NAME)) %>% 
  mutate(`Total Earnings` = as.numeric(gsub("[,$]", "", `TOTAL EARNINGS`)))

average2020 <- earnings2020 %>% 
  group_by(DEPARTMENT_NAME) %>% 
  summarise (mean_gross = mean(`Total Earnings`))

earnings2021 <- read_csv("employee-earnings-report-2021.csv") %>% 
  filter(grepl('Department', DEPARTMENT_NAME)) %>% 
  rename(`Total Earnings` = TOTAL_GROSS)

average2021 <- earnings2021 %>% 
  group_by(DEPARTMENT_NAME) %>% 
  summarise(mean_gross = mean(`Total Earnings`))

average2022<- df %>% 
  group_by(DEPARTMENT_NAME) %>% 
  summarise(mean_gross = mean(TOTAL_GROSS))

#-----combining the dataframes

average2011$year <- 2011
average2012$year <- 2012
average2013$year <- 2013
average2014$year <- 2014
average2015$year <- 2015
average2016$year <- 2016
average2017$year <- 2017
average2018$year <- 2018
average2019$year <- 2019
average2020$year <- 2020
average2021$year <- 2021
average2022$year <- 2022


dfs <- list(average2011, average2012, average2013, average2014, average2015,
            average2016, average2017, average2018, average2019, average2020,
            average2021, average2022)

# Finding common departments
common_departments <- reduce(dfs, function(df1, df2) {
  inner_join(df1, df2, by = "DEPARTMENT_NAME") %>%
    select(DEPARTMENT_NAME)
})

# Filter all dataframes to only have common departments
dfs_filtered <- map(dfs, function(df) {
  filter(df, DEPARTMENT_NAME %in% common_departments$DEPARTMENT_NAME)
})

# Combine all dataframes
all_averages <- bind_rows(dfs_filtered)




library(RColorBrewer)

color_scale <- c(
  "Boston Police Department" = "#377EB8",
  "Boston Fire Department" = "#E41A1C",
  "Environment Department" = "#4DAF4A",
  "Parks Department" = "#A65628",
  "Assessing Department" = "#FFFF33",
  "Auditing Department" = "#FF7F00",
  "Law Department" = "#984EA3",
  "Public Works Department" = "#F781BF"
)


line_plot <- ggplot(all_averages, aes(x = year, y = mean_gross, group = DEPARTMENT_NAME, color = DEPARTMENT_NAME)) +
  geom_line(size = 1.25) +
  labs(title = "Boston Departments Average Earnings over the years",
       x = "Year",
       y = "Dollars ($)",
       color = "Department",
       caption = paste("Source: data.boston.gov", "github.com/connoraking", sep = "\n")) +
  theme_economist() +
  scale_x_continuous(breaks = 2011:2022, limits = c(2011, 2022)) + 
  scale_y_continuous(breaks = c(50000, 100000, 150000)) +
  scale_color_manual(values = color_scale) +
  #scale_colour_viridis(discrete = TRUE) +
  theme(axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0))) 

line_plot

ggsave(filename = "line_plot.png", plot = line_plot, width = 13, height = 7, dpi = 300)
