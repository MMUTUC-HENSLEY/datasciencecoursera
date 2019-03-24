#Getting and Cleaning Data 
#Programming Assignment

#Check Work Directory
getwd()

#Load Packages
library(data.table)
library(dplyr)

#Set Work Directory
setwd("C:/Users/mmutuc/Documents/DataScience/Getting_Cleaning_Data/Programming_Assignment")

#Download Zip Files 
URL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

#Check If File Exists, Unzip and Save, Specify Date Downloaded
DestFile <- "Data.zip"
if (!file.exists(DestFile)){download.file(URL, destfile = DestFile, mode = 'wb')}

if (!file.exists("./UCI_HAR_Dataset")){unzip(DestFile)}

date_downloaded <- date()

#Browse Files
setwd("~/DataScience/Getting_Cleaning_Data/Programming_Assignment/UCI HAR Dataset")

#Read Activity Files
ActivityTest <- read.table("./test/y_test.txt", header = F)
ActivityTrain <- read.table("./train/y_train.txt", header = F)

#Read Features Files
FeaturesTest <- read.table("./test/X_test.txt", header = F)
FeaturesTrain <- read.table("./train/X_train.txt", header = F)

#Read Subject Files
SubjectTest <- read.table("./test/subject_test.txt", header = F)
SubjectTrain <- read.table("./train/subject_train.txt", header = F)

#Read Activity Labels and Features Names
ActivityLabels <- read.table("./activity_labels.txt", header = F)
FeaturesNames <- read.table("./features.txt", header = F)

#Merge Test and Training Data: Features, Subject and Activity
FeaturesData <- rbind(FeaturesTest, FeaturesTrain)
SubjectData <- rbind(SubjectTest, SubjectTrain)
ActivityData <- rbind(ActivityTest, ActivityTrain)
                            
#Rename ActivityData and ActivityLabels Columns
names(ActivityData) <- "ActivityN"
names(ActivityLabels) <- c("ActivityN", "Activity")
                            
#Left Join Factor of Activity Names                            
Activity <- left_join(ActivityData, ActivityLabels, "ActivityN")[, 2]
                            
#Rename SubjectData and FeaturesData Columns                            
names(SubjectData) <- "Subject"
names(FeaturesData) <- FeaturesNames$V2
                            
#Create Large Dataset                            
DataSet <- cbind(SubjectData, Activity)                            
DataSet <- cbind(DataSet, FeaturesData)
                            
#Extract Measurements on the Mean and Standard Deviation for Each Measurement
SubFeaturesNames <- FeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", FeaturesNames$V2)]
                            
#Create Dataset
DataNames <- c("Subject", "Activity", as.character(SubFeaturesNames))                          
DataSet <- subset(DataSet, select = DataNames)
                            
#Use Descriptive Activity Names to Name Activities in Data Set
names(DataSet)<-gsub("^t", "time", names(DataSet))                            
names(DataSet)<-gsub("^f", "frequency", names(DataSet))                            
names(DataSet)<-gsub("Acc", "Accelerometer", names(DataSet))                            
names(DataSet)<-gsub("Gyro", "Gyroscope", names(DataSet))                            
names(DataSet)<-gsub("Mag", "Magnitude", names(DataSet))                            
names(DataSet)<-gsub("BodyBody", "Body", names(DataSet))
                            
#Create Second Dataset - Tidy Data Set with Average of Each Variable by Activity and by Subject
DataSet2 <- aggregate(. ~Subject + Activity, DataSet, mean)                            
DataSet2 <- DataSet2[order(DataSet2$Subject, DataSet2$Activity),]
                            
write.table(DataSet2, file = "tidydata.txt",row.name = FALSE)
                            