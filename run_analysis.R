## 
## JHU Science Specialization, Getting and Cleaning Data
## Peer-graded Assignment: Getting and Cleaning Data Course Project
## Created by: cchagnon
## Created on: 2017-04-18
## 

library(dplyr)

## Download and unzip the data for the project
srcURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(srcURL, "< working directory  > uci-har.zip")
unzip(zipfile="uci-har.zip")

# - Read the results data
testX <- read.table("UCI HAR Dataset/test/X_test.txt")
trainX <- read.table("UCI HAR Dataset/train/X_train.txt")

# - Read the 'activity' keys for matching results data
testY <- read.table("UCI HAR Dataset/test/y_test.txt")
trainY <- read.table("UCI HAR Dataset/train/y_train.txt")

# - Read the 'subject' keys for matching results data
testSubject <- read.table("UCI HAR Dataset/test/subject_test.txt")
trainSubject <- read.table("UCI HAR Dataset/train/subject_train.txt")

# - Read the signal descriptions (column names for results)
signals <- read.table('UCI HAR Dataset/features.txt')

# - Create 'test' results dataset
colnames(testY) <- "activityId"
colnames(testSubject) <- "subjectId"
colnames(testX) <- signals[,2]
testResults <- cbind(testY, testSubject, testX)

# - Create 'train' results dataset
colnames(trainY) <-"activityId"
colnames(trainSubject) <- "subjectId"
colnames(trainX) <- signals[,2] 
trainResults <- cbind(trainY, trainSubject, trainX)

###
### 1. Merge 'train' and 'test' to create one dataset
###
allResults <- as.data.frame(rbind(trainResults, testResults))
valid_column_names <- make.names(names=names(allResults), unique=TRUE, allow_ = TRUE)
names(allResults) <- valid_column_names
allResults <- tbl_df(allResults)

###
### 2. Extract only the measurements on the mean and standard deviation for each measurement
###
resultsMeanStd <- select(allResults, activityId, subjectId, contains("mean"), contains("std"))

###
### 3. Use descriptive activity names for the activities in the dataset
###
activities = read.table('UCI HAR Dataset/activity_labels.txt')
colnames(activities) <- c('activityId','activityName')

###
### 4. Appropriately label the dataset with descriptive variable names.
###
resultsMeanStd <- inner_join(resultsMeanStd, activities, by='activityId')

###
### 5. From the dataset in step 4, create a second, independent tidy dataset with
###    the average of each variable for each activity and each subject
###
resultsMeanStdAvg <- group_by(resultsMeanStd, subjectId, activityId, activityName) %>% 
    summarise_each(funs(mean))

### Output file to submit
write.table(resultsMeanStdAvg, "resultsMeanStdAvg.txt", row.name=FALSE)

