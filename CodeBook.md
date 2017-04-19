Getting And Cleaning Data - Course Project
================
Charles A. Chagnon
2017-04-18

### Codebook

See [README.md](README.md) for further detail on the source data used.

**Primary Record Identifiers**
- subject: The integer ID of the test subject

-   activity: The integer ID of the activity performed when the corresponding measurements were taken

**Activity Labels**
Indicate that during the measurement:

1.  WALKING: Subject was walking

2.  WALKING\_UPSTAIRS: Subject was walking up a staircase

3.  WALKING\_DOWNSTAIRS: Subject was walking down a staircase

4.  SITTING: Subject was sitting

5.  STANDING: Subject was standing

6.  LAYING: Subject was lying down

**Measures**
561 columns of data as described above. Floating-point numbers representing 3-axial linear acceleration and angular velocity as measured by a smartphone's accelerometer and gyroscope:

-   tBodyAcc-mean()-X

-   tBodyAcc-mean()-Y

-   tBodyAcc-mean()-Z

-   tBodyAcc-std()-X

-   tBodyAcc-std()-Y

-   etc.

### Solution

A rundown of the steps taken in the file run\_analysis.R.

###### Download and unzip the data for the project

    srcURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(srcURL, "< working directory  > uci-har.zip")
    unzip(zipfile="uci-har.zip")

###### Read the results data

The extracted files are found in the "UCI HAR Dataset" subfolder, under '/test' and '/train', filenames begin with 'X\_'

    testX <- read.table("UCI HAR Dataset/test/X_test.txt")
    trainX <- read.table("UCI HAR Dataset/train/X_train.txt")

###### Read the keys for matching results data

The extracted files are found in the "UCI HAR Dataset" subfolder, under '/test' and '/train', filenames begin with 'y\_'

    testY <- read.table("UCI HAR Dataset/test/y_test.txt")
    trainY <- read.table("UCI HAR Dataset/train/y_train.txt")

###### Read the 'subject' keys for matching results data

The extracted files are found in the "UCI HAR Dataset" subfolder, under '/test' and '/train', filenames begin with 'subject\_'

    testSubject <- read.table("UCI HAR Dataset/test/subject_test.txt")
    trainSubject <- read.table("UCI HAR Dataset/train/subject_train.txt")

###### Read the signal descriptions (column names for results)

The extracted file is found in the "UCI HAR Dataset" subfolder, and contains the column names for each measure.

    signals <- read.table('UCI HAR Dataset/features.txt')

###### Create 'test' and 'train' results datasets, apply column names.

    colnames(testY) <- "activityId"
    colnames(testSubject) <- "subjectId"
    colnames(testX) <- signals[,2]
    testResults <- cbind(testY, testSubject, testX)

    colnames(trainY) <-"activityId"
    colnames(trainSubject) <- "subjectId"
    colnames(trainX) <- signals[,2] 
    trainResults <- cbind(trainY, trainSubject, trainX)

###### 1. Merge 'train' and 'test' to create one dataset

Once the source data has been read into datasets with column names, the datasets can be merged into one dataframe. There are duplicate alues in the source data, so make.names() is used to make each column distinct.

    allResults <- as.data.frame(rbind(trainResults, testResults))
    valid_column_names <- make.names(names=names(allResults), unique=TRUE, allow_ = TRUE)
    names(allResults) <- valid_column_names
    allResults <- tbl_df(allResults)

###### 2. Extract only the measurements on the mean and standard deviation for each measurement

dplyr select() is used to create a dataset containing just the columns with names containing 'mean' and 'std'

    resultsMeanStd <- select(allResults, activityId, subjectId, contains("mean"), contains("std"))

###### 3. Use descriptive activity names for the activities in the dataset

The extracted file is found in the "UCI HAR Dataset" subfolder.

    activities = read.table('UCI HAR Dataset/activity_labels.txt')
    colnames(activities) <- c('activityId','activityName')

###### 4. Appropriately label the dataset with descriptive variable names.

dplyr inner\_join() is used to associate the 'activity labels' with each activtyID.

    resultsMeanStd <- inner_join(resultsMeanStd, activities, by='activityId')

###### 5. From the dataset in step 4, create a second, independent tidy dataset with the average of each variable for each activity and each subject

The final dataset is created by chaining dplyr group\_by() and summarize\_each() onto the above dataset.

    resultsMeanStdAvg <- group_by(resultsMeanStd, subjectId, activityId, activityName) %>% 
        summarize_each(funs(mean))

###### Output file to submit

    write.table(resultsMeanStdAvg, "resultsMeanStdAvg.txt", row.name=FALSE)
