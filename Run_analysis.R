library(dplyr)
library(reshape2)

filename <- "getdata_wk4.zip"

## Download the dataset:
if (!file.exists(filename)){
        fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
        download.file(fileURL, filename, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
        unzip(filename) 
}

# Load activity labels + features
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Extract only the data on mean and standard deviation
featuresfil <- grep(".*mean.*|.*std.*", features[,2])
featuresfil.names <- features[featuresfil,2]
featuresfil.names = gsub('-mean', 'Mean', featuresfil.names)
featuresfil.names = gsub('-std', 'Std', featuresfil.names)
featuresfil.names <- gsub('[-()]', '', featuresfil.names)


# Load the datasets
train <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresfil]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresfil]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# merge datasets
totaldata <- rbind(train, test)
colnames(totaldata) <- c("subject", "activity", featuresfil.names)

# turn activities & subjects into factors
totaldata$activity <- factor(totaldata$activity, levels = activityLabels[,1], labels = activityLabels[,2])
totaldata$subject <- as.factor(totaldata$subject)
names(totaldata)<-gsub("^t", "time", names(totaldata))
names(totaldata)<-gsub("Acc", "Accelerometer", names(totaldata))
names(totaldata)<-gsub("Gyro", "Gyroscope", names(totaldata))
names(totaldata)<-gsub("Mag", "Magnitude", names(totaldata))
names(totaldata)<-gsub("BodyBody", "Body", names(totaldata))
names(totaldata)<-gsub("^f", "frequency", names(totaldata))

totaldata.melted <- melt(totaldata, id = c("subject", "activity"))
totaldata_avg <- dcast(totaldata.melted, subject + activity ~ variable, mean)

names(totaldata_avg)
str(totaldata_avg)
write.table(totaldata_avg, "tidydata.txt", row.names = FALSE, quote = FALSE)