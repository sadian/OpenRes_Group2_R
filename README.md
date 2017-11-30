# Marriage Equality Referendum Data


## Research question 1: Who participated the vote?

## Participation by States and Gender
![Figure1](Participation_by_states_and_gender.png)


12,727,920 (79.5%) eligible Australians participated in the Australian Marriage Law Postal Survey.  

The participation rates in most of states were around 80%, except for North Terriory where less than 60% eligible Australians responded. 

Meanwhile, there were more female responding than male in all the states with a difference around 5%. Nationally 81.1% eligible female participated compared with 77.3% male. 

Senior citizens were more likely to reply the postal survey, with 87.2% of eligible Australian over 60 years old participating. Whereas the participation rate was lowest in the age group of 25-34 at 72.2%.


## Research question 2: 
## Are different age groups correlated based on their participation patterns?
![Figure2](Age_correlations.png)



## Research question 3: What states had the highest and lowest “Yes” votes?


We wanted to know the percentage of people that voted Yes and No in each state.

![Figure3](Yes_per_state.png) 
![Figure3](Yes_ResBas.jpeg) 

The graphs below show that ACT had the highest percentage of Yes votes in the country!
Victoria came in second :)

![Figure4](No_per_state.png) 
![Figure5](No_ResBas.jpeg)


New South Wales had the highest percentage of No voters.




## Research question 4: Can gender or age predict the “Yes” vote?

We did not have the “Yes” vote data broken down by age or gender unfortunately...
But...statistics!
We wondered if we could relate the participation rates broken down by gender and age to the outcome of the vote in each electorate.  
Turns out we can! 
![Figure5](gender_yes.png)


Using linear regression we found a significant relationship between the gender ratio (female to male) of those who participated and the outcome in the electorate. The more women that participated compared to men, the higher the rate of YES votes.
Outliers of note: Sydney had a lower female ratio of participation but still very high yes votes.
Disclaimer: Of course we cannot say that women voted yes more, as we do not have that data.  There could be other variables involved (such as urban versus rural, age etc.) that influence both gender ratios and yes voting.
But still quite interesting! :)

![Figure6](20s_Yes.png)

This plot looks at the rate of 25-29 year olds compared to other age groups and whether that is related to “Yes” votes.
The higher the amount of 25-29yr-olds in an electorate the higher the rate of “Yes” votes.

Another take-away from this graph is that it looks like NSW may be a polarised state, it has some of the highest and lowest rates of “Yes” voting.

![Figure7](oldies_yes.png)

Finally we examined whether the amount of the oldest Australians (over 85) voting in an electorate influenced the YES vote.
There was no relationship with the levels of over 85s and the outcome.


## Research question 5:Can different FED be correlated based on their participation patterns - Cluster analysis?
### Clustering Tendency 
![Text displayed for visually impaired](figure/visual_assessment_of_clustering_tendency1.png)

### Cluster 
![Figure8](FED_clustering_analysis.png)

## Outlier elimination
![Text displayed for visually impaired](outlier_elimination.png)
