
setwd("C:/Users/Suman/Desktop/Coursera/Data Science Specialization lectures/3. Getting and Cleaning Data/Week 4/Course Project")

## download zip file & save in current working directory
if(!file.exists("./data")){dir.create("./data")}
if(!file.exists("./data/Dataset.zip")){
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",destfile="./data/Dataset.zip")
}

## Unzip dataSet to /data directory
if(!file.exists("./data/UCI HAR Dataset")){
unzip(zipfile="./data/Dataset.zip",exdir="./data")
}

library(dplyr)

# read training data
X_train <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
Y_train <- read.table("./data/UCI HAR Dataset/train/Y_train.txt")
Sub_train <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")

# read test data
X_test <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
Y_test <- read.table("./data/UCI HAR Dataset/test/Y_test.txt")
Sub_test <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")

# Merge respective datasets
X_data <- rbind(X_train, X_test)
Y_data <- rbind(Y_train, Y_test)
Sub_data <- rbind(Sub_train, Sub_test)

# Add labels for respective datasets
Features <- read.table("./data/UCI HAR Dataset/features.txt")
colnames(X_data)<-Features[,2]
colnames(Y_data)<- "Activity_ID"
colnames(Sub_data)<- "Subject_ID"

# Merge all datasets into one dataset
Total_data <- cbind(X_data,Sub_data,Y_data)   #---- Requirement 1

# Get complete column list
colList_Total <- colnames(Total_data)

# Get relevant column list
ColList_Relevant <- (
                 grepl("mean()" , colList_Total) | 
                 grepl("std()" , colList_Total)  |
				 grepl("Activity_ID" , colList_Total) | 
                 grepl("Subject_ID" , colList_Total)
                 )
# Extract only the measurements on the mean and standard deviation for each measurement - includes Activity_ID & Subject_ID
Relevant_data <- Total_data[,ColList_Relevant==TRUE]   #---- Requirement 2


# Uses descriptive activity names to name the activities in the data set
activityLabels <- read.table('./data/UCI HAR Dataset/activity_labels.txt')
colnames(activityLabels)<- c("Activity_ID","Activity_Name")

# Add activity names using Activity_ID as the unique column
Relevant_data_with_Activity_Names <- merge(Relevant_data, activityLabels,
                              by='Activity_ID',
                              all.x=TRUE)   #---- Requirement 3

# Appropriately labels the data set with descriptive variable names.		  
names(Relevant_data_with_Activity_Names)<-gsub("^t", "time", names(Relevant_data_with_Activity_Names))   #---- Requirement 4
names(Relevant_data_with_Activity_Names)<-gsub("^f", "frequency", names(Relevant_data_with_Activity_Names))
names(Relevant_data_with_Activity_Names)<-gsub("Acc", "Accelerometer", names(Relevant_data_with_Activity_Names))
names(Relevant_data_with_Activity_Names)<-gsub("Gyro", "Gyroscope", names(Relevant_data_with_Activity_Names))
names(Relevant_data_with_Activity_Names)<-gsub("Mag", "Magnitude", names(Relevant_data_with_Activity_Names))
names(Relevant_data_with_Activity_Names)<-gsub("BodyBody", "Body", names(Relevant_data_with_Activity_Names))

# From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject
# 30 subjects X 6 activities = 180 rows
AverageDataSet <- aggregate(. ~Subject_ID + Activity_ID, Relevant_data_with_Activity_Names, mean)
AverageDataSet <- TidyDataSet[order(TidyDataSet$Activity_ID, TidyDataSet$Activity_ID),]    
write.table(AverageDataSet, "Tidy.txt", row.name=FALSE)     #---- Requirement 5

