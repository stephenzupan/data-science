require(rpart)
require(rpart.plot)
require(rattle)
require(caret)
require(dplyr)

email <-read.csv('~/Downloads/email.csv', header = TRUE, row.names = 1)

str(email)

email$spam <-factor(email$spam)
email$re_subj <-factor(email$re_subj)
email$cc <-factor(email$cc)
email$image <-factor(email$image)

email_clean <-na.omit(email)

rows_test <-sample(1:nrow(email_clean),floor(0.1*nrow(email_clean)))
email_test <- email_clean[rows_test,]
email_train <- email_clean[-rows_test,]


treemod <-rpart(spam~num_char+line_breaks+number+winner+re_subj+cc+image,
                data = email_train,
                method ='class',
                control =rpart.control(minsplit = 25))

# The fancy tree visualization
fancyRpartPlot(treemod, sub = "")

# predictions for spam and not spam
pred <-predict(treemod, email_test)

# attach predictions to dataframe
email_test$spam_score <- pred[,2]

# select desired columns from df
test_pred <- email_test%>% select(spam, spam_score)

# arrange dataframe with descending (best to worst) scores
test_pred <- test_pred%>% arrange(desc(spam_score))
test_pred$pred <- 0

# use the best 20% for predicting
top_scores <-floor(nrow(test_pred)*0.2)
test_pred$pred[1:top_scores] <- 1

# create a table with the confusion matrix, run function with the table as the argument
pred_tab <-table(test_pred$pred,test_pred$spam)
confusionMatrix(pred_tab, positive = "1")

# positive predicted value metric
precision(pred_tab, relevant ='1')

# sensitivity metric (recall)
recall(pred_tab, relevant ='1')

# because these metrics don't mean much on their own, its a good idea to use a loop to run several
# models and determine the best one

# Here, let’s look at an example where we go through different minsplit values and maxdepth 
# (how many steps we can go from the root node), as well as choosing a different percentage 
# to predict as spam.

# We will look at minsplit values of 5, 10, 15, 20
splits <-c(5,10,15,20)

# We'll look at maxdepths of 2, 3, 4, 5
depths <-c(2,3,4,5)

# We'll consider predicting the top 5%, 10%, and 20% as spam
percent <-c(.05, .1, .2)

# How many different models are we running?
nmods <-length(splits)*length(depths)*length(percent)

# We will store results in this data frame
results <-data.frame(splits =rep(NA,nmods),depths =rep(NA, nmods),percent =rep(NA,nmods),precision =rep(NA,nmods),recall =rep(NA,nmods))
# The model number that we will iterate on (aka models run so far)
mod_num <- 1
# The loop
for(i in 1:length(splits)){
  for(j in 1:length(depths)){
    s <- splits[i]
    d <- depths[j]
    # Running the model
    treemod <-rpart(spam~num_char+line_breaks+number+winner+re_subj+cc+image,
                    data = email_train,
                    method ='class',
                    control =rpart.control(minsplit = s, maxdepth = d))
    # Find the prediction
    spred <-predict(treemod, email_test)
    
    # Attach scores to the test set
    # Then sort by descending order
    email_test$spam_score <- pred[,2]
    test_pred <- email_test%>% select(spam, spam_score)%>%
      arrange(desc(spam_score))
    
    # Make predictions based on scores
    # We loop through each threshold value here.
    for(k in 1:length(percent)){
      p <- percent[k]
      # Predict the top % as 1
      test_pred$pred <- 0
      top_scores <-floor(nrow(test_pred)*p)
      test_pred$pred[1:top_scores] <- 1
      # Confusion Matrix
      pred_tab <-table(test_pred$pred, test_pred$spam)
      # Store results
      results[mod_num,] <-c(s, 
                            d, 
                            p, 
                            precision(pred_tab, relevant = "1"),
                            recall(pred_tab, relevant = "1"))
      # Increment the model number
      mod_num <- mod_num+1}}}
# All results are stored in the "results" dataframe
head(results)

#Best recall? Top 5 in descending order
results%>% arrange(desc(recall))%>% head()

# Best precision? Top 5 in descending order
results%>% arrange(desc(precision))%>% head()

# Create a list of 10 folds (each element has indices of the fold)
flds <-createFolds(email_clean$spam, k = 10, list = TRUE, returnTrain = FALSE)
str(flds)

# Create train and test using fold 1 as test
email_test01 <- email_clean[flds$Fold01,]
email_train01 <- email_clean[-flds$Fold01,]

