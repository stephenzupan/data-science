# import necessary packages
import pandas as pd
from sklearn.tree import DecisionTreeClassifier
from sklearn.model_selection import train_test_split
from sklearn import metrics
from sklearn.metrics import classification_report
import numpy as np

# link to kaggle dataset
# https://www.kaggle.com/ronitf/heart-disease-uci

# read dataset into pandas dataframe
df = pd.read_csv('../../Desktop/Data/heart.csv', header = 0)

# we will drop the 'cp' column, as it is a patient's gauging of their own pain
df.drop(['cp'], axis = 1)

# define feature columns to use in decision tree
cols = ['age', 'sex', 'cp', 'trestbps', 'chol',
        'fbs', 'restecg', 'thalach', 'exang',
        'oldpeak', 'slope', 'ca', 'thal']

X = df[cols]
y = df['target']

# a little train test split action
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=1) # 70% training and 30% test

# create decision tree classifer object
clf = DecisionTreeClassifier()

# train the decision tree
clf = clf.fit(X_train,y_train)

# predict on test dataset
y_pred = clf.predict(X_test)

# model accuracy, how often is the classifier correct?
print("Accuracy: ",metrics.accuracy_score(y_test, y_pred))

# additional metrics of model including precision and accuracy
print(classification_report(y_test, y_pred))
