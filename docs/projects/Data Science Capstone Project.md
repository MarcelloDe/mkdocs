---
layout: post
title: "Data Science Capstone Project"
subtitle: "Project Spotlight"
date: 2025-10-26
---


# 🚀 Capstone Project: Quantifying Perception & Predicting Work Intentions in Hamilton, ON

***

## 1. Project Overview: Bridging NLP and Predictive Analytics

This capstone project, completed for the **McMaster Data Science Analytics** program, delivered an end-to-end analytical solution for the City of Hamilton's economic development office.

The central goal was to understand and predict **McMaster University alumni's work and residency intentions** regarding Hamilton, a city actively working to transition its economy from heavy industry to a knowledge-based sector. We moved beyond traditional survey analysis by combining **Natural Language Processing (NLP)** and **Predictive Modeling (Logistic Regression)** to provide actionable, evidence-based strategy recommendations.

| Analysis Component | Objective | Key Tool |
| :--- | :--- | :--- |
| **Text Mining (NLP)** | Understand **_how_** people describe Hamilton (unfiltered public perception). | R (`tm`, `wordcloud`) |
| **Predictive Modeling** | Determine **_which_** perceptions drive the decision to work in Hamilton. | Python (`scikit-learn`) |

***

## 2. NLP & Text Mining Methodology: Extracting the Public Voice 🗣️

The first phase transformed over **1,190 raw, open-ended descriptions** of Hamilton from the `hamiltonDesc` survey field into quantifiable insights using R's text mining capabilities.

### Text Cleaning and Corpus Creation (R Code)

This pipeline prepared the messy, raw text for accurate frequency counting.

```r
# Load necessary libraries
library(tm)
library(tidyverse)

# 1. Combine all individual text descriptions into one string
mydata_text <- paste(mydata$hamiltonDesc, collapse=" ")

# 2. Convert string to a corpus object
mydata_source <- VectorSource(mydata_text)
corpus <- Corpus(mydata_source)

# 3. Apply Text Cleaning Pipeline
corpus <- tm_map(corpus, content_transformer(tolower))      # Convert to lowercase
corpus <- tm_map(corpus, removePunctuation)                  # Remove punctuation
corpus <- tm_map(corpus, stripWhitespace)                    # Remove extra spaces
corpus <- tm_map(corpus, removeWords, stopwords("english"))  # Remove stopwords (e.g., 'the', 'a')


Word Frequency Analysis and Visualization (R Code)
A Document-Term Matrix (DTM) was created to quantify word frequency, which was then visualized as a word cloud.

# 4. Create Document-Term Matrix
dtm <- DocumentTermMatrix(corpus)
dtm2 <- as.matrix(dtm)

# 5. Calculate and sort word frequencies
frequency <- colSums(dtm2)
frequency <- sort(frequency, decreasing=TRUE)

# 6. Generate Word Cloud (Word size proportional to frequency)
library(wordcloud)
words <- names(frequency)
wordcloud(words[1:25], frequency[10:70])


Key Findings: Predominant Themes
The most frequent terms were growing, improving, and developing, confirming that the city's revitalization is widely recognized. Other high-frequency terms like diverse and vibrant highlighted its cultural assets, though terms like industrial and steel showed the historical identity persists.

3. Predictive Modeling: Identifying Decision Drivers 🧠
The second phase built a Logistic Regression Model to determine which perception factors were the most statistically significant drivers of a respondent's interest in Hamilton-based employment.

Model Setup and Training (Python Code)
This Python example outlines the core structure for training the predictive model using scikit-learn.

import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression

# Load the sanitized dataset (post-cleaning)
df = pd.read_csv("WorkIntentionsSanitized.csv")

# Define target variable (Y) and independent variables (X)
# Y: Binary variable 'Are you interested in Hamilton based employment?'
Y = df['Hamilton_Work_Intent'] 

# X: Perception ratings for Safety, Culture, and Career Opportunities (1-10 scale)
X = df[['Safety_Perception', 'SocialLife_Perception', 'CareerOpps_Perception']]

# Split data for training and testing
X_train, X_test, Y_train, Y_test = train_test_split(X, Y, test_size=0.3, random_state=42)

# Initialize and Train the Logistic Regression Model
model = LogisticRegression()
model.fit(X_train, Y_train)

# Output Model Accuracy
accuracy = model.score(X_test, Y_test)
print(f"Model Accuracy: {accuracy:.2f}") 
# Result: Model Accuracy averaged ~0.70, indicating good predictive power

Key Model Insights
Safety is Paramount: The model coefficients showed that a positive perception of city safety was the single most powerful predictor of employment intent.

Career Focus: High ratings for career opportunities were the second most influential factor.

Culture Secondary: Perception of social life/culture was a weaker driver of employment intent.

4. Technical Challenges & Solutions: The Cleaning Hurdle
A significant portion of the project (approximately 90%) was dedicated to data preprocessing due to poor data quality common in non-time-series, non-standardized surveys.

The Challenge: The survey included non-rigid, open-ended fields that resulted in inconsistent spelling, varying capitalization, and non-standardized answers (e.g., 'Hamilton' was spelled over ten different ways).

The Solution: We used a combination of Python string matching logic and Tableau's visual grouping capabilities to standardize inconsistent categorical answers. Missing and unreasonable numerical values (e.g., ages > 1000) were replaced with the mean of the corresponding feature.

5. Comprehensive Conclusion and Actionable Strategy 💡
The integrated analysis delivered a clear, evidence-based strategy for the City of Hamilton.

<table style="width:100%;"> <thead> <tr> <th style="width:25%; text-align:left;">Finding Category</th> <th style="width:75%; text-align:left;">Policy Recommendation</th> </tr> </thead> <tbody> <tr> <td><b>Perception Gap</b></td> <td><b>Invest in Public Relations:</b> Actively promote the city's growing and vibrant assets while directly addressing the negative perception of safety and the lingering industrial identity.</td> </tr> <tr> <td><b>Decision Drivers</b></td> <td><b>Prioritize Safety & Investment:</b> Focus policy and budget on improving city safety and security, as this is the primary psychological hurdle for attracting knowledge workers. Additionally, continue efforts to attract companies that offer competitive Career Opportunities.</td> </tr> <tr> <td><b>Data Strategy</b></td> <td><b>Annualize and Redesign the Survey:</b> Implement a rigid, structured survey annually. This will reduce the massive data cleaning burden and allow for longitudinal tracking of public perception in response to new city policies.</td> </tr> </tbody> </table>

This capstone project delivered a complete analytical solution, moving from raw, messy data to an end-to-end NLP pipeline and a powerful predictive model, directly addressing a critical municipal economic challenge.

Project Status: Completed (McMaster University Data Science Analytics Capstone) Languages: R, Python Dataset: Work Intentions Survey - Hamilton, Ontario (n=1,190) Analysis Type: Text Mining, Predictive Modeling, Data Preprocessing