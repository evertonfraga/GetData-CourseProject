# GetData-CourseProject

This document describes the step-by-step on how to transform and summarize triaxial acceleration and angular velocity of typical body movements. The data was drawn from UCI Machine Learning Repository.

Dataset URL: 
[http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones]

10299 samples


Step-by-step

1) Read and merge test and training datasets.

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

2) Extract only mean and standard deviation columns.

```r
extract_mean_std <- function(df){
  df[grep("(mean|std)\\.", colnames(df))]
}

```

3) Name activities that were mere numbers on original raw file.

```r
name_activities <- function(activity_data){
  activities <- c("WALKING", "WALKING_UPSTAIRS", "WALKING_DOWNSTAIRS", "SITTING", "STANDING", "LAYING")
  lapply(activity_data, function(x) activities[x])
}
```

4) A series of replaces to make column names more readable.
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

5) Grouping data by Subject id and Activity name; Summarising every other column by its mean value.

```r
library(dplyr)
averages <- data %>% group_by(Subject, Activity) %>% summarise_each(funs(mean))

```

6) Writing out the tidy data

```r
write.csv(data, file="tidydata.txt", col.names=FALSE)
```


