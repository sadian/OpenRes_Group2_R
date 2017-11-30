options(prompt = "R> ", repos =  "http://cran.rstudio.com/")

library(tibble)
library(readr)
library(dplyr)

# read data
#total = read.csv(file.choose(), header =T)  
# list what file you picked manually, hard to remember which file you choosed...
total = read.csv("C:/Users/Sadia/Desktop/OpenRes/ResponseTotal.csv")
AMLPS = read.csv("C:/Users/Sadia/Desktop/OpenRes/AMLPS_RESP_2017_17112017134913689.csv")
female = read.csv("C:/Users/Sadia/Desktop/OpenRes/ResponseFemale.csv")
male = read.csv("C:/Users/Sadia/Desktop/OpenRes/ResponseMale.csv")


# Check the states data
# get rid of duplicates
AMLPS = distinct(AMLPS)
female = distinct(female)
male = distinct(male)
total = distinct(total)


# For regression or even  clustering, I need to filter selected entries from the AMLPS file as below:
(temp_amlps = AMLPS %>%
              filter(ï..RESPONSE_CAT %in% c("RESPCLR_Y") & #,"EP_NCLR","RESPCLR_N") &
                        MEASURE == 2)) # to get responses in percent
temp_total = total %>% 
              filter(Participation == "Participation rate (%)")


#data merging temp total and temp AMLPS when AMLPS is only Yes Response
new_temp_total =  merge(temp_amlps,temp_total,
                    by.x = "Federal.Electoral.Division",
                    by.y = "FederalElectoralDivison")

#get rid of extra columns
new_temp_total$ï..RESPONSE_CAT = NULL
new_temp_total$MEASURE = NULL
new_temp_total$REGIONTYPE = NULL
new_temp_total$Geography.Level = NULL
new_temp_total$AEC_FED_2017 = NULL
new_temp_total$TIME = NULL
new_temp_total$Year = NULL
new_temp_total$Flag.Codes = NULL
new_temp_total$Flags = NULL
new_temp_total$Response = ifelse(new_temp_total$Response == "Response clear - Yes", 'Yes', 'NA')
colnames(new_temp_total)[4] = 'Response Yes Value(%)'
new_temp_total$Measure = NULL
colnames(new_temp_total)[21] = 'Participation rate(%)'
new_temp_total$Participation = NULL


(temp_amlps = AMLPS %>%
    filter(ï..RESPONSE_CAT %in% c("RESPCLR_N") & #,"EP_NCLR","RESPCLR_Y") &
              MEASURE == 2)) # to get responses in percent


#data merging new temp total and temp AMLPS when AMLPS is only No Response
temp_total =  merge(new_temp_total,temp_amlps,   # we don't need temp_total variable so let's overwrite it
               by = "Federal.Electoral.Division")

#Let's clean this new file, get rid of extra columns
temp_total$ï..RESPONSE_CAT = NULL
temp_total$MEASURE = NULL
temp_total$REGIONTYPE = NULL
temp_total$Geography.Level = NULL
temp_total$AEC_FED_2017 = NULL
temp_total$TIME = NULL
temp_total$Year = NULL
temp_total$Flag.Codes = NULL
temp_total$Flags = NULL
temp_total$Response.y = ifelse(temp_total$Response.y == "Response clear - No", 'No', 'NA')
colnames(temp_total)[23] = 'Response No Value(%)'
colnames(temp_total)[3] = 'Response Yes Value(%)'
temp_total$Measure = NULL

#let's re-order columns
temp_total$`Response_Yes(%)` = temp_total$`Response Yes Value(%)`
temp_total$`Response_No(%)` = temp_total$`Response No Value(%)`
temp_total$Response.x = NULL
temp_total$`Response Yes Value(%)` = NULL
temp_total$Response.y = NULL
temp_total$`Response No Value(%)` = NULL

(temp_amlps = AMLPS %>%
    filter(ï..RESPONSE_CAT %in% c("EP_NCLR") & #,"RESPCLR_N","RESPCLR_Y") &
              MEASURE == 2)) # to get responses in percent
colnames(temp_amlps)[11] = "Response_Unlear(%)"
temp_amlps$Flag.Codes = NULL
temp_amlps$Flags = NULL
temp_amlps$TIME = NULL
temp_amlps$Year = NULL
temp_amlps$REGIONTYPE = NULL
temp_amlps$ï..RESPONSE_CAT = NULL
temp_amlps$MEASURE = NULL
temp_amlps$Measure = NULL
temp_amlps$Geography.Level = NULL
temp_amlps$AEC_FED_2017 = NULL
temp_amlps$Response = NULL

# merge the response NOT clear data frame with the previous  temp_total

new_temp_total =  merge(temp_total,temp_amlps,   # we don't need temp_total variable so let's overwrite it
                    by = "Federal.Electoral.Division")


# to identify least and most participating groups by age through their mean, media and sd
mean_participation_by_age[order(mean_participation_by_age=sapply(new_temp_total[c(2:15)], mean))]
median_participation_by_age[order(median_participation_by_age=sapply(new_temp_total[c(2:15)], median))]
stdDev_participation_by_age[order(stdDev_participation_by_age = sapply(new_temp_total[c(2:15)], sd))]


# the following graph shows how the age groups be defined
library("corrplot")
cor.mat <- round(cor(new_temp_total[c(2:16)]),2)  # rounding off to two digits
corrplot(cor.mat, type="lower", order="hclust", diag = T, outline = T,
         title = "correlation plot of normalized input variables",
         # title.cex = 0.9,
         # order = "hclust",
         # hclust.method = 'ward.D2',
         # diag = T,
         tl.cex = 0.8, tl.col="black", tl.srt=45)
#' age groups of interest should be
#' Group 1: 18-54
#' Group 2: 55-74
#' Group 3: 75-onwards

# Scatterplot Matrices from the glus Package 
# the plot shows as the age increases, the participation patterns become more correlated
library(cluster)
library(gclus)
#dta <- na.omit(norm_df_std[c(-1,-3:-4,-8)]) # get data after skipping missing valued rows 
dta = new_temp_total[c(2:16)]
dta.r <- abs(cor(dta)) # get absolute values of correlations 
#so only positive correlations are plotted
dta.col <- dmat.color(dta.r) # get colors
# reorder variables so those with highest correlation
# are closest to the diagonal
dta.o <- order.single(dta.r) 
cpairs(dta, dta.o, panel.colors=dta.col, gap=.5,
       main="Variables Ordered and Colored by Correlation" )


#' Befor clustering or any other analysis, ensure data is outlier free
#'  ++++++++++++++++++++++++++++++++++++++++++++++++++++
#'
#'  Local Outlier factor (Density based methods):
#'
#'  ++++++++++++++++++++++++++++++++++++++++++++++++++++  
library(grid)
library(DMwR)


#Let's compute the outlier scores of the numeric data (based on 25 nearest neighbours)
outlier.scores = lofactor(new_temp_total[c(2:21)], k = 25)
#Let's plot the outlier scores
plot(density(outlier.scores))
#most values are on left, values near far right can have potential outliers

# Now obtain the top ten outliers in this data
outliers = order(outlier.scores, decreasing = T)

#To visualize outliers with first two principal components
n = nrow(new_temp_total[c(2:21)])# count no. of rows in data
labels = 1:n                          # label each row with its row number
labels[-outliers[1:5]] = " . "       # mark all rows with . except the outliers
biplot(prcomp(new_temp_total[c(2:21)]), cex = 0.8, xlabs = labels)

pch = rep(".", n)               # choosing the character symbol for each data row
pch[outliers[1:5]] = "+"       # choosing the character symbol for outliers
col = rep("black", n)           # choosing the colour for each data row
col[outliers[1:5]] = "red"     # choosing the colour for outliers
pairs((new_temp_total[c(2:21)]), pch = pch, col = col)
chart.Correlation(new_temp_total[c(2:21)], histogram=TRUE, pch=pch, col = col)

library(rgl)
plot3d((new_temp_total[c(2:21)]), type = "s", col = col)
# from this 3D image, it appears, so apparent outliers in data



#'  ++++++++++++++++++++++++++++++++++++++++++++++++++++
#'
#'  CLUSTERING ANALYSIS
#'
#'  ++++++++++++++++++++++++++++++++++++++++++++++++++++  
#' Loading the required packages for clustering analysis
library(ggplot2)
library(factoextra)
library(clustertend)
library(seriation)
library(gdata)

#' ----------------------
#' Visual approach:
#' ----------------------

#' VAT: Visual Assessment of cluster Tendency:
#' This approach can be used to visually inspect the clustering tendency of the dataset.
#' As well as getting a numeric value Hopkins statistic for finding tendency

get_clust_tendency(new_temp_total[c(2:21)], 100)

get_clust_tendency(new_temp_total[c(2:21)], n=146, graph = TRUE, 
                   gradient = list(low = "black", mid = "white", high = "blue"), 
                   seed = 123)
# Perhaps 9 clusters

#' Hopkins statistic is 0.04504 . close to zero means, clusterable
# VAT suggests 4 clusters

#'  ++++++++++++++++++++++++++++++++++++++++++++++++++++
#'
#'  PARTITIONING METHOD:
#'  
#'  Finding the number of clusters by the elbow method
#'
#'  ++++++++++++++++++++++++++++++++++++++++++++++++++++  
#'  
#'=============
#' Method 1:
#'=============
wss <- (nrow(new_temp_total[c(2:21)])-1)*sum(apply(new_temp_total[c(2:21)],2,var))

# The for loop is suggesting: we want no more than 20 clusters
for (i in 1:20) 
  wss[i] <- sum(kmeans(new_temp_total[c(2:21)], centers=i)$withinss)
plot(1:20, wss, type="b", 
     main = "Optimal number of clusters - originl data",
     xlab="Number of Clusters K",
     ylab="Within groups sum of squares")
abline(v = 3, lty =2, col = 'blue')
# 5 -8 could be the number of clusters

#'=============================================
#'         Hierarchical Clustering
#'=============================================
#' Step2: Package load into the library
library(RWeka)

row.names(new_temp_total) = new_temp_total[,1]
#' find distance
distance = dist(new_temp_total[c(2:21)], method = "minkowski")
# prepare hierarchical cluster using ward,D2 method
hc = hclust(distance, method = "ward.D2")
str(hc)

#' For hierarchical clustering we need to install the following package
library(NbClust)
library(fpc)

fviz_dend(hc,  
          k = 9,  
          k_colors = c("aquamarine4", "coral2", "cornflowerblue", "chartreuse",
                       "brown", "gold","red","purple"),
          show_labels = T,
          color_labels_by_k = T,
          cex = 0.5, 
          rect = T
          )#, 


res <- hcut(new_temp_total[c(2:21)], k = 4, stand = TRUE)
# Visualize
fviz_dend(res, rect = TRUE, cex = 0.5,
          #k_colors = c("aquamarine4", "coral2", "cornflowerblue","pink","chocolate1", "chartreuse"))
          k_colors = c("deepskyblue1", "mediumpurple1", "hotpink","yellowgreen"))
#k_colors = c("#00AFBB","#FC4E07"))
str(res)
res$size


# How to make logistic regression model on the response variable

#' Step 1:

# Define the required response variable
response = c('Response clear - No',"Response clear - Yes")

#' Filter data from the AMLPS file
sub_AMLPS = AMLPS %>%
             filter(Response %in% response & Geography.Level == 'Federal Electoral Division')

# data cleaning
# rather than dropping these features, we can alternatively just not incude them in the model

sub_AMLPS$Flag.Codes = NULL
sub_AMLPS$Flags = NULL
# year and time stay the same throughout so get rid of them
sub_AMLPS$Year = NULL
sub_AMLPS$TIME = NULL
#' Since the data has been filtered and we are only looking at the federal elctoral division
#' we can thus, also get rid of REGIOTYPE and Geography.Level
sub_AMLPS$REGIONTYPE = NULL
sub_AMLPS$Geography.Level = NULL
#' Now for each federal electoral division we have four entries
#' Two yes, Two no's. 2 are in numbers and two are in percent.
#' We should  keep the percents only to avoid data normalization issues
sub_AMLPS = sub_AMLPS %>%
             filter(MEASURE == 2)

sub_AMLPS$MEASURE = NULL
sub_AMLPS$Measure = NULL
sub_AMLPS$AEC_FED_2017 = NULL # already have that as Federal.Electoral.Division
sub_AMLPS$ï..RESPONSE_CAT = NULL

#' so in our logistic model, we want to see which electoral divisions 
#' can be related based on 
#' 1. response type: Yes/No 
#' 2. participation rate: how much was the turn out 
#' 3. not clear responses: carelessness

#---------------------------------
#   SIMPLE LOGISTIC REGRESSION 
#---------------------------------
sub_AMLPS$output = ifelse(sub_AMLPS$Response == "Response clear - Yes", 1, 0)

#now we can also get rid of Response variable
sub_AMLPS$Response = NULL

library(caTools)
set.seed(123)
split = sample.split(sub_AMLPS,SplitRatio = 0.7)
train_data = subset(sub_AMLPS, split == T)
test_data = subset(sub_AMLPS,split == F)

table(sub_AMLPS$output)
table(sub_AMLPS$Federal.Electoral.Division)
with(sub_AMLPS,table(output,Federal.Electoral.Division))

#model fitting
model = glm(output~.,family = binomial(link = 'logit'),data = train_data)
summary(model)

#analyze the table of deviance
anova(model,'chisq')

#model predictive ability


states = c("New South Wales (Total)", "Victoria (Total)", "Queensland (Total)", "South Australia (Total)", 
           "Western Australia (Total)", "Tasmania (Total)", "Northern Territory (Total)", 
           "Australian Capital Territory (Total)", "Australia (Total)")

test_m = male %>%
  group_by(FederalElectoralDivison) %>%
  filter(FederalElectoralDivison %in% states)

test_fm = female %>%
  group_by(FederalElectoralDivison) %>%
  filter(FederalElectoralDivison %in% states)

test_m
test_fm
# lots of duplicates in the data so we first need to get our data clean

# dplyr has a very SQL like function
dup_free_female = distinct(female)
dup_free_male = distinct(male)

test_m = dup_free_male %>%
  filter(FederalElectoralDivison %in% states, Participation %in% "Participation rate (%)")
test_fm = dup_free_female %>%
  filter(FederalElectoralDivison %in% states, Participation %in% "Participation rate (%)")

# Let's try to plot bar graphs
library(ggplot2)
library(ggrepel)

a_m = test_m %>%
      filter(Participation == "Participation rate (%)") 

a_fm = test_fm %>%
  filter(Participation == "Participation rate (%)") 


#a$FederalElectoralDivison = as.factor(a$FederalElectoralDivison)
str(a$FederalElectoralDivison)
str(a$Participation)


ggplot(a_m,aes(a_m$FederalElectoralDivison,a_m$Total.Males.b.,)) +
  geom_bar(aes(a_m$FederalElectoralDivison,a_m$Total.Males.b.))#a_m$FederalElectoralDivison,a_m$Total.Males.b.)

par(mfrow=c(1,2))
barplot(a_m$Total.Males.b., xlab = 'States', ylab = '%Male Participation', names.arg = a_m$FederalElectoralDivison, beside = T)
barplot(a_fm$Total.Females.b., xlab = 'States', ylab = '%Female Participation', names.arg = a_fm$FederalElectoralDivison, beside = T)


for_plot = cbind(a_m$FederalElectoralDivison,a_m$Total.Males.b.,a_fm$Total.Females.b.)
for_plot = as.data.frame(for_plot) 
for_plot$V2 = as.numeric(as.character(for_plot$V2))
for_plot$V3 = as.numeric(as.character(for_plot$V3))

#for column renaming
#library(plyr)
#rename(for_plot, c("V1"="State_names","V2"="Males", "V3"="Females"))
#str(for_plot)

library(tidyr)
for_plot %>%
  gather(V2,V3,key='gender',value="participation (%)") %>%
  ggplot() +
  geom_bar(aes(y=`participation (%)`,x=V1, fill=gender),stat = 'identity',position = "dodge")+
  coord_flip()+
  scale_fill_manual(values = c("blue", "Red"), name = "State/Gender", labels = c("Male ","Female"))


#scale_fill_manual

#Yes/No
state = c("New South Wales", "Victoria", "Queensland", "South Australia", 
          "Western Australia", "Tasmania", "Northern Territory", 
          "Australian Capital Territory", "Australia")


test_ampls = AMLPS %>% 
  filter(Response %in% c("Response clear - Total", "Response clear - Yes", "Response clear - No")) %>%
  filter(Measure == 'Percentage (%)' & `Federal Electoral Division` %in% state)

yes <- test_ampls[which(test_ampls$Response == "Response clear - Yes"),]
no <- test_ampls[which(test_ampls$Response == "Response clear - No"),]

state_response_yes = cbind((yes$`Federal Electoral Division`),as.numeric(yes$Value))
as.data.frame(state_response_yes)

state_response_no =cbind(no$`Federal Electoral Division`,no$Value)
as.data.frame(state_response_no)

library(tibble)
summarise(yes)





plot(as.factor(a_m$FederalElectoralDivison), a_m$Total.Persons, type="b", 
     main = "females per state",
     xlab = "State",
     ylab = "Percent Participation",
     pch = 19, frame = T)

abline(lm(a$Total.Persons ~ a$FederalElectoralDivison, data = a), col ="blue")
lines(lowess(a$Total.Persons ~ a$FederalElectoralDivison), col = "red")


library(car)
scatterplot((a$Total.Persons ~ a$FederalElectoralDivison),data = a)

colors = c("red","green","yellow","orange","blue","pink","purple","gold")

library(scatterplot3d)
x = c(a$X18.19.years,a$X20.24.years)
y = c(a$X25.29.years,a$X30.34.years)
z= c(a$X35.39.years,a$X40.44.years)
grps = as.factor(a$FederalElectoralDivison)

scatterplot3d(x,y,z,pch=16,color = colors[grps])

(female$FederalElectoralDivison)
unique(female$FederalElectoralDivison)
unique(female$Participation)
table(female$Participation)

library(dplyr)
library(ggplot2)

states = c("New South Wales (Total)", "Victoria (Total)", "Queensland (Total)", "South Australia (Total)", 
           "Western Australia (Total)", "Tasmania (Total)", "Northern Territory (Total)", 
           "Australian Capital Territory (Total)", "Australia (Total)")

test = female %>%
  group_by(FederalElectoralDivison) %>%
  filter(FederalElectoralDivison %in% states) %>%
  ggplot() + 
  geom_bar(aes(x=FederalElectoralDivision)


female %>%
    filter(Participation == 'Participation rate (%)') %>% 
             filter(Total.Persons > 90) %>%  
    ggplot() +
    geom_bar(aes(x = FederalElectoralDivison, y = "Total.Persons")) + theme_minimal()


install.packages("get_map")
library(ggplot2)
library(ggmap)
library(get_map)




library(googleVis)
Geo = gvisGeoMap(Population,locationvar = "Country",
                 numvar = "Population",options = list(height=350,dataMode = 'regions'))
plot(Geo)
input=read.csv("http://www.rci.rutgers.edu/~rwomack/Rexamples/UNdata.csv",header = T)
Map = data.frame(input$Country.or.Area,input$Value)
names(Map) = c("Country", "Age")
Geo=gvisGeoMap(Map,locationvar = "Country",numvar = "Age",
               options = list(height=350,dataMode='regions'))
plot(Geo)
M = gvisMotionChart(Fruits,idvar = "Fruit",timevar = "Year")
plot(M)
