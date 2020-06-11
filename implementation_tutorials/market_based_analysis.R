# https://rpubs.com/cyobero/market_basket_analysis
library(arules)

groceries <- read.csv("../Downloads/groceries.csv", header = FALSE)
head(groceries)

groceries <- read.transactions("../Downloads/groceries.csv", sep=',')
summary(groceries)

inspect(groceries[1:10])

itemFrequency(groceries[, 1:4])

grocery.rules <- apriori(groceries, parameter = list(support = 0.003, confidence = 0.25, minlen = 2))

grocery.rules

summary(grocery.rules)

inspect(grocery.rules[1:10])

inspect(sort(grocery.rules, by = 'lift')[1:20])


# https://cran.r-project.org/web/packages/arules/vignettes/arules.pdf
# 5.2. Example 2: Preparing and mining a questionnaire data set

data("AdultUCI")
