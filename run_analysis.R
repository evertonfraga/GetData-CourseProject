library(data.table)
setwd(file.path("","Users","ev","Coursera","3 Getting and Cleaning Data","Course Project","data"))

# 1) Merges the training and the test sets to create one data set.
#    - Read X, Y and subject test and train files
#    - put them together on a data structure
#    - merge Train and Test data into one data set.

# 2) Extracts only the measurements on the mean and standard deviation for each measurement. 
#    - names() <- features
#    - ["mean" | "std]
# 3) Uses descriptive activity names to name the activities in the data set

extract_mean_std <- function(df){
  df[grep("(mean|std)\\.", colnames(df))]
}

name_activities <- function(activity_data){
  # TODO: Read from file
  activities <- c("WALKING", "WALKING_UPSTAIRS", "WALKING_DOWNSTAIRS", "SITTING", "STANDING", "LAYING")
  lapply(activity_data, function(x) activities[x])
}

sets <- c("test", "train")
feature_col_names <- as.character(read.table("features.txt")$V2)
data <- NULL

for(set in sets){
  x_filename <- paste("X_", set, ".txt", sep = "")
  x_data_tmp <- read.table(file.path(set, x_filename), col.names = feature_col_names)
  x_data <- extract_mean_std(x_data_tmp)
  
  y_filename <- paste("y_", set, ".txt", sep="")
  y_data <- read.table(file.path(set, y_filename), col.names = c('Activity'))
  y_data <- name_activities(y_data)
  
  subject_filename <- paste("subject_", set, ".txt", sep="")
  subject_data <- read.table(file.path(set, subject_filename), col.names = c('Subject'))
  
  data <- rbind(data, cbind(subject_data, y_data, x_data))
}



# 4) Appropriately labels the data set with descriptive variable names. 
#   What we're doing here is mutating the row names through a series of replaces, in order to make them more readable.
#   eg: from "tBodyAcc.mean(Z)" to "BodyAccelerationZMean"

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

# 5) From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

library(dplyr)

averages <- data %>% group_by(Subject, Activity) %>% summarise_each(funs(mean))
write.csv(data, file="tidydata.txt", col.names=FALSE)

