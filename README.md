# Get Data - Course Project

This document provides the step-by-step on how to transform and summarize triaxial acceleration and angular velocity of typical body movements. The data - which was generated using motion processors on a Samsung Galaxy SIII - can be downloaded from UCI Machine Learning Repository.

Dataset URL: 
http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

The dataset provides:

* 10299 samples
* 561 measures for each sample
* 6 motion activity types


## Step-by-step on cleaning up data

### 1. Read and merge test and training datasets.

Using a list with values 'test' and 'train' we pass it into a for loop and perform the following operations.

```r
sets <- c("test", "train")
feature_col_names <- as.character(read.table("features.txt")$V2)
data <- NULL

for(set in sets){
  x_filename <- paste("X_", set, ".txt", sep = "")
  x_data <- read.table(file.path(set, x_filename), col.names = feature_col_names)
  x_data <- extract_mean_std(x_data)
  
  y_filename <- paste("y_", set, ".txt", sep="")
  y_data <- read.table(file.path(set, y_filename), col.names = c('Activity'))
  y_data <- name_activities(y_data)
  
  subject_filename <- paste("subject_", set, ".txt", sep="")
  subject_data <- read.table(file.path(set, subject_filename), col.names = c('Subject'))
  
  data <- rbind(data, cbind(subject_data, y_data, x_data))
}

```

### 2. Extract only mean and standard deviation columns.

Using Regular Expressions, we were able to detect and filter only the desired columns: those regarding Mean and Std values.

```r
extract_mean_std <- function(df){
  df[grep("(mean|std)\\.", colnames(df))]
}

```

### 3. Name activities that were mere numbers on original raw file.

Simply replacing numbers ranging from 1 to 6 to their actual labels.

```r
name_activities <- function(activity_data){
  activities <- c("WALKING", "WALKING_UPSTAIRS", "WALKING_DOWNSTAIRS", "SITTING", "STANDING", "LAYING")
  lapply(activity_data, function(x) activities[x])
}
```

### 4. A series of replaces to make column names more readable.

In order to having more readable column names, a 

```r
col <- colnames(data)
colnames(data) <- lapply(col, function(x){
  # Removing all dots from column names
  x <- gsub("\\.+", "", x, perl=T)
  
  # Expanding initial letters 't' and 'f'
  x <- gsub("^t", "Time", x, perl=T)
  x <- gsub("^f", "Feature", x, perl=T)
  
  # Expanding words
  x <- gsub("Acc", "Acceleration", x, perl=T)
  
  # Camel case on the words 'mean' 'std'
  x <- gsub("mean", "Mean", x, perl=T)
  x <- gsub("std", "Std", x, perl=T)
})
```

### 5. Summarising data
Using dplyr library, was possible to group data by Subject id and Activity name. Every other column was summarised using the Mean function.

```r
library(dplyr)
averages <- data %>% group_by(Subject, Activity) %>% summarise_each(funs(mean))
```

### 6. Writing out the tidy data

Time to write this out to a flat txt file.

```r
write.csv(data, file="tidydata.txt", col.names=FALSE)
```


