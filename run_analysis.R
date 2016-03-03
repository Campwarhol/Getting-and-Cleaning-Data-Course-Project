#Assigning Getting and Cleaning Data Course Project
#Download the Samsumg triaxial acceleration dataset
#Merging the traning and test sets to create one data set
#Then extracting the measurements on the mean and stand deviations for each measurement
#update the dataset with a more description activity name
#Label the data set with descriptive variable names

if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip")

oldpath <- getwd()
setwd("./data")

# Unzip the dataset and place it into the /data folder
unzip(zipfile = "./Dataset.zip")

setwd(oldpath)

#create a list of the file paths that are in the expanded zip folder "UCI HAR Dataset"
filepaths <- file.path("./data",  "UCI HAR Dataset")
#create a list of the files in the paths to character set files
files <- list.files(filepaths, recursive = TRUE)

#there are two subdirectories one for test data the other for train
#in each there is a X-test and a Y-test and a x-train and y-train data.

#loading from the subdirectory test the Y-train into data.frame
dataActivityTrain <- read.table(file.path(filepaths, "train", "Y_train.txt"),header = FALSE)

#loading from the subdirectory test the Y-test into data.frame
dataActivityTest <- read.table(file.path(filepaths, "test", "Y_test.txt"),header = FALSE)

#load the subjects train and test into data.frame(s)
dataSubjectTrain <- read.table(file.path(filepaths, "train", "subject_train.txt"),header = FALSE)
dataSubjectTest <- read.table(file.path(filepaths, "test", "subject_test.txt"),header = FALSE)

#Read Features train and test into data.frame(s)
dataFeaturesTrain <- read.table(file.path(filepaths, "train", "X_train.txt"),header = FALSE)
dataFeaturesTest <- read.table(file.path(filepaths, "test", "X_test.txt"),header = FALSE)

#part 2 of the assignment is to merge the two data sets
#using rbind to merge the two data sets by rows and assign the data to new variables.
MergedActivity <- rbind(dataActivityTrain, dataActivityTest)
MergedSubject <- rbind(dataSubjectTrain, dataSubjectTest)
MergedFeatures <- rbind(dataFeaturesTrain, dataFeaturesTest)

#set the names of the variables
names(MergedActivity)<- c("activity")
names(MergedSubject)<-c("subject")

#extract the the featues from the text file features.txt. "1 tBodyAcc-mean()-X 2 tBodyAcc-mean()-Y 3 tBodyAcc-mean()...."
dataFeaturesNames <- read.table(file.path(filepaths, "features.txt"),head=FALSE)
names(MergedFeatures) <- dataFeaturesNames$V2

#concatenate the data frames subject to activity 
dataConcatenate <- cbind(MergedSubject, MergedActivity) 
#concatenate the data frames of features to Merged and activity
Finaldata <- cbind(MergedFeatures, dataConcatenate)

#from the final merged and concatenated data frame we extract the mean and standard deviation for each measurement.
subdataFeaturesNames<-dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]
selectedNames<-c(as.character(subdataFeaturesNames), "subject", "activity" )

Finaldata <- subset(Finaldata,select=selectedNames)

# In the file "activity_labels.txt" contains the activity labeling 
#"1 WALKING
#2 WALKING_UPSTAIRS
#3 WALKING_DOWNSTAIRS
#4 SITTING
#5 STANDING
#6 LAYING
#extract the above labels  
activityLabels <- read.table(file.path(filepaths, "activity_labels.txt"),header = FALSE)

#breakdown the activity label in the data set 
head(Finaldata$activity,30)

#and replace the labels in the FinalData with decriptive names
names(Finaldata)<-gsub("^t", "time", names(Finaldata))
names(Finaldata)<-gsub("^f", "frequency", names(Finaldata))
names(Finaldata)<-gsub("Acc", "Accelerometer", names(Finaldata))
names(Finaldata)<-gsub("Gyro", "Gyroscope", names(Finaldata))
names(Finaldata)<-gsub("Mag", "Magnitude", names(Finaldata))
names(Finaldata)<-gsub("BodyBody", "Body", names(Finaldata))



#load required library
library(plyr)
DataTidy <- aggregate(. ~subject + activity, Finaldata, mean)
DataTidy<-DataTidy[order(DataTidy$subject,DataTidy$activity),]

#create the tidy data set and export as a txt file.
write.table(DataTidy, file = "tidydata.txt",row.name=FALSE)



