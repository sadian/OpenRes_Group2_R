peds_new = read.csv("C:/Users/Sadia/Desktop/OpenRes/Pedestrian_data/pedestriancounts_melbourne.csv")
peds_new2= read.csv("C:/Users/Sadia/Desktop/OpenRes/Pedestrian_data/Pedestrian_sensor_locations.csv")

#Challenge 1
apply(peds_new, 2, 
                 function(x)
                  (sum(is.na(x))))

sapply(peds_new, function(x) length(unique(x)))

(peds_NA = sapply(peds_new, 
                 function(x)
                   (sum(is.na(x)))))

#Challenge 2
peds_new2$Date_Time = as.POSIXct(peds_new2$'Upload.Date', format = "%d/%m/%Y")


library(dplyr)
#it gives new data frame
Sunday_peds = peds_new %>%
              filter(Day_of_week == "Sunday")# %>% View
# perhaps tricky to use it here
unique(Sunday_peds$Day_of_week)
summary(as.factor(Sunday_peds$Day_of_week))

# Challenge 3
weekend_peds = peds_new %>%
                filter(Day_of_week == "Sunday" | Day_of_week == "Saturday")# %>% View
summary(as.factor(weekend_peds$Day_of_week))

Friday_peds = peds_new %>%
              filter(Day_of_week == "Friday" & Hour == '18')

weekdayPeds = peds_new %>%
              filter(Day_of_week != "Sunday" & Day_of_week != "Saturday")# %>% View

weekdayPeds = peds_new %>%
  filter(!Day_of_week == "Sunday" & !Day_of_week == "Saturday")# %>% View

summary(weekdayPeds)


pedFilter = c("Saturday", "Sunday")
weekend_peds = peds_new %>%
                filter(Day_of_week %in% pedFilter)



v1 = c(10,10,10,10,10)
v1 == (10,5)
v1 %in% (10,5)


#Challenge 4
peds_new %>%
  group_by(Day_of_week) %>%
  summarise(mean1 = mean(PedestrianCount))

peds_new %>%
  group_by(Day_of_week) %>%
  summarise(mean1 = mean(PedestrianCount,na.rm = T))


#Total count for each day of week
table(peds_new$Day_of_week)

# do it for each hour
peds_new %>% 
  group_by(Hour) %>%
  summarise(mean2 = mean(PedestrianCount,na.rm = T))


peds = read_csv("C:/Users/Sadia/Downloads/Pedestrian_volume__updated_monthly_ (1).csv")
library(ggplot2)

peds %>% 
  group_by(Day) %>%
  summarise(meancount = mean(Hourly_Counts)) %>%
    ggplot() +
      geom_bar(aes(x=Day,y=meancount), stat = "identity") 
# do not count how many rows rather plot the numbers we used

ggplot(peds) +
  geom_bar(aes(x=Month))  # it counts the number of rows where that Month appeared

# Challenge 5
table(peds$Sensor_Name)
unique(peds$Sensor_Name)

sensor_names = c("Queen St (West)", "Southbank", "New Quay", "Webb Bridge", "State Library")

set.seed(123)
sensor_names = sample(unique(peds$Sensor_Name), size = 5)

peds %>%
  group_by(Sensor_Name) %>%
  filter(Sensor_Name %in% sensor_names) %>%
  summarise(mean_count = mean(Hourly_Counts)) %>%
    ggplot() +
      geom_bar(aes(x=Sensor_Name,y =mean_count), stat="identity")

peds$Month = as.factor(peds$Month)

summer = c("November","December","January","February")
spring = c("August","September","October")
fall = c("March","April")
winter = c("May","June","July")

peds$season = if_else(peds$Month %in% summer,"Summer",
                     if_else(peds$Month %in% spring,"Spring",
                        if_else(peds$Month %in% winter, "Winter","Fall")))

color_season = c("Fall","Spring","Summer","Winter")
peds %>%
  group_by(season) %>%
  summarise(means  = mean(Hourly_Counts)) %>%
    ggplot() +
      geom_bar(aes(x=season, y = means, fill=color_season), stat = "identity", size = 10) +
  theme_minimal() 



peds %>%
  filter(Month %in% summer)
  group_by(Month) %>%
    
    
##############
  
#  My practice

#############
  options(prompt = "R> " )
  library(readr)
  peds = read_csv("C:/Users/Sadia/Downloads/Pedestrian_volume__updated_monthly_ (1).csv")
  str(peds)
  peds$Month = as.factor(peds$Month)
  
  
  (peds_NA = apply(peds, 2, function(x)
    (sum(is.na(x)))))
  
  peds$New_Date_Time = as.POSIXct(peds$Date_Time,format = "%d-%b-%Y %H:%M")
  str(peds)
  summary(peds)
  
  library(dplyr)
  fridaydata  = peds %>% filter(Day == "Friday")
  
  weekenddata = peds %>% filter(Day == "Saturday" | Day == "Sunday")
  str(weekenddata$Day)
  
  friday_data = peds %>% filter(Day == "Friday", Time == '18')
  
  weekdaydata = peds %>% filter(!Day %in% c("Saturday","Sunday"))
  weekdaydata = peds %>% filter(!Day == "Saturday" & !Day == "Sunday")
  
  peds %>% 
    group_by(Day) %>%
    summarize(sd = sd(Hourly_Counts), mean = mean(Hourly_Counts), median = median(Hourly_Counts))
  
  (day_count = table(peds$Day))
  
  str(peds)
  
  (month_count = table(peds$Month))
  round(summary(peds$Month)/2009009, 2)
  
  
  result = (peds %>%
              group_by(Month) %>%
              summarise(mean = mean(Hourly_Counts)))
  
  library(tibble)
  result %>% arrange(mean)
  
  peds %>%
    filter(Day == "Friday") %>%
    group_by(Sensor_Name) %>%
    summarise(mean = mean(Hourly_Counts))
  
  unique_names = as.factor(peds$Sensor_Name)
  
  
  library(ggplot2)
  peds %>%
    group_by(Day) %>%
    summarise(meanCount = mean(Hourly_Counts)) %>%
    ggplot() +
    geom_bar(aes(y = meanCount, x = Day), stat = identity)
  
  ggplot(peds) +
    geom_bar(aes(x=Month))