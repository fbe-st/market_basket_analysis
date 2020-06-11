# Market Basket Analysis

## Motivation
We are interested in learning patterns of sequences of events and actions carried out by our users when using our product. Our objective is to understand the prior probabilities of sequences of events, in order to predict the next most likely event given a sequence, and suggest them to our users to drive engagement and better use of the product.

Market Basket Analysis (MBA) is an approach which solves this exact problem, but in the context of transactional data. We explore MBA as a potential candidate for producing a "next-best action" recommender system.

## Background

_Taken from: https://rpubs.com/cyobero/market_basket_analysis_

Market basket analysis is an unsupervised learning technique that can be useful for analyzing transactional data. It can be a powerful technique in analyzing the purchasing patterns of consumers.

Market basket analysis is an association rule method that identifies associations in transactional data. It is an unsupervised machine learning technique used for knowledge discovery rather than prediction. This analysis results in a set of association rules that identify patterns of relationships among items. A rule can typicall be expressed in the form:

                    {peanut butter, jelly}→{bread}
                    
The above rule states that if both peanut butter and jelly are purchased, then bread is also likely to be purchased.

### The Apriori Algorithm
In real life, transactional data can often be complex and enormous in volume. Transactional data can be extremely large both in terms of the quantity of transactions and the number of items monitored. Given k items that can either appear or not appear in a set, there are 2k possible item sets that must be searched for rules. Thus, even if a retailer only has 100 distinct items, he could have 2100=1e+30 item sets to evaluate, which is quite an impossible task. However, a smart rule learner algorithm can take advantage of the fact that in reality, many of the potential item combinations are rarely found in practice. For example, if a retailer sells both firearms and dairy products, a set of {gun, butter} are extremely likely to be common. By ignoring these rare cases, it makes it possible to limit the scope of the search for rules to a much more manageable size.

To resolve this issue Aragawal and R. Srikant introduced the apriori algorithm. The apriori algorithm utilizes a simple prior belief (hence the name a priori) about the properties of frequent items. Using this a priori belief, all subsets of frequent items must also be frequent. This makes it possible to limit the number of rules to search for. For example, the set {gun, butter} can only be frequent if {gun} and {butter} both occur frequently. Conversely, if neither {gun} nor {butter} are frequent, then any set containing these two items can be excluded from the search.

There are two statistical measures that can be used to determine whether or not a rule is deemed “interesting”:

- Support: Measures how frequently an item set occurs in the data. It can be calculated as:

                    Support(X) = Count(X) / N
                    
where X represents an item and N represents the total number of transactions.

- Confidence: Measures the algorithm’s predictive power or accuracy. It is calculated as the support of item X and Y divided by the support of item X.

              Confidence(X→Y) = Support(X,Y) / Support(X)
              
The important thing to note regarding confidence is that Confidence(X→Y) ≠ Confidence(Y→X). 

### How the Apriori Algorithm Works
The way in which the apriori algorithm creates rules is relatively straightforward.

1. Identify all item sets that meet a minimum support threshold: This process occurs in multiple iterations. Each successive iteration evaluates the support of storing a set of increasingly large items. The first iteration involves evaluating the set of of 1-item sets. The second iteration involves evaluating the set of 2-item sets, and so on. The result of each iteration i is a set of i-itemsets that meet the minimum threshold. All item sets from iteration i are combined in order to generate candidate item sets for evaluation in iteration i+1. The apriori principle can eliminate some of the items before the next iteration begins. For example, if {A}, {B}, and {C} are frequent in iteration 1, but {D} is not, then the second iteration will only consider the item sets {A, B}, {A, C}, and {B, C}.
2. Create rules from these items that meet a minimum confidence threshold.

# RESULTS

PROS:

- Intuitive, relatively cheap computationally.
- Very similar to PMI.
   - The lift measure is very similar to PMI's joint probability over the product of the individual probabilities -> log p(y,x)/p(x)*p(y)
- The lift measure can be a good candidate for the "next-best action" recommendation feature.

CONS:
- Seems more valuable for when you have thousands/millions of different elements.
   - We are currently considering only a very small set of potential actions users can do using the product.
   - Because of this, many of the results are intuitive for domain experts without the need for unsupervised ML.
   - Would be valuable if we expand the set to include not just work items, but all type of different activities, events, and triggers/decisions.
- Misses self loops (i.e. quantities/frequecies of the same product/activity)
   - Buying one bottle of milk significantly reduces the probability of buying a second bottle, but…
   - Buying one can of beer significantly increases the probability or buying a second bottle of beer.
   - This might relate to our case as in creating one project doesn't increase the p of creating a new one, while creating one task does increase the p of creating a new task.
- The apriori algorithm discards elements with low support (frequency of occurrence) in the first passes.
   - If there's an activity which happens seldom but is very important (e.g. a quality gate), which happens only after a series of very specific events, we would not see this activity as belonging to a rule, as it'll have been discarded in the first iteration.
