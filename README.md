# Boston Public Data Analysis
Analyzing and creating data visualizations on public Boston Data from [data.boston.gov](data.boston.gov)

## Table of Contents

1. [Department Earnings](#department-earnings)
    - [2022](#2022)
    - [Throughout the Years](#throughout-the-years)
3. [Fire Incidents](#fire-incidents)

## Department Earnings

Using datasets from these [earning reports](https://data.boston.gov/dataset/employee-earnings-report)

### 2022

![](./Department_Earnings/stacked_2022_earnings.png)<!-- -->

### _Data breakdown_

#### Overall Earnings
- The Boston Fire Department has the highest average gross earnings for 2022 at $157,168.68.
- The Strategy Department has the lowest average gross earnings at $64,350.30.

#### Base Salary
- The Boston Fire Department has the highest average base salary of $114,767.73.
- The Parks Department has the lowest average base salary of $47,775.02.

#### Overtime

- The Boston Police Department has the highest average overtime earnings at $25,745.20.
- The Environment and Strategy Departments have virtually no overtime earnings.

#### Injury Pay

- Both Boston Police Department and Boston Fire Department have considerable injury pay, with the Fire Department leading at $8,310.33.
- Several departments, including the Auditing, Public Facilities, Environment, Strategy, and Law Departments, have no injury pay.

#### Education Incentive

- The Boston Police Department is primarily the only department to earn education incentive payments with an average of $9,230.27.
- From [mass.edu](https://www.mass.edu/osfa/initiatives/pcipp.asp): "The Police Career Incentive Pay Program, also known as the Quinn Bill, was enacted by the Massachusetts Legislature to encourage police officers to earn degrees in law enforcement and criminal justice.  It provides educational incentives for regular full-time officers in participating cities and towns through salary increases."

#### Other

- The Strategy Department has the highest average other earnings at $9,394.63.
- The Public Works Department has the least in this category at $1,782.80.

### Throughout the Years

*Note: this line graph only includes departments that had continious earnings data since 2011 as some departments had data on some years and none within the others. They were omitted for visualization and analysis purposes.*

![](./Department_Earnings/line_plot.png)<!-- -->

### _Key Observations_

- **High Grossing Departments:** The Boston Fire Department and the Boston Police Department consistently have higher average gross earnings compared to other departments. This is likely due to the nature of their roles, risks involved, and possible overtime or special duty allowances. They were seemingly on par with each other until the Fire Department saw a large increase from 2018-2019. There could be several reasons behind this spike such as contraction negotiations and retroactive pay. The City of Boston and its unions, including the fire department's union, have had a history of protracted negotiations, which sometimes led to such retroactive payouts. Specific records from the Boston Fire Department, the City of Boston's official statements, or union announcements from that time frame would lead to further definitive analysis behind the hike. 
- **Steady Growth:** Almost all departments have seen growth in their average gross earnings over the 12-year period. This could be due to annual raises, inflation adjustments, or an increased focus on specialized roles and responsibilities.
- **Fluctuations:** Some departments like the Environment Department and Parks Department have seen fluctuations in their earnings, indicating possible changes in department size, roles, or budget allocations.

## Fire Incidents

Using the dataset from these [fire reports](https://data.boston.gov/dataset/fire-incident-reporting)

![](./Fire_incidents/incident_years.png)<!-- -->

![](./Fire_incidents/incident_hours.png)<!-- -->

![](./Fire_incidents/incident_months.png)<!-- -->

![](./Fire_incidents/incident_choro.png)<!-- -->

![](./Fire_incidents/incident_word_cloud.png)<!-- -->

![](./Fire_incidents/incident_prop_word_cloud.png)<!-- -->
