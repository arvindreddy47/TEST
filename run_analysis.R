filename <- "getdata_dataset.zip"

if (!file.exists(filename)){
  download.file(url = paste("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", 
                            sep = ""), 
                destfile = filename, mode = 'wb',cacheOK = FALSE)
}

if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}


activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
str(activityLabels)
activityLabels[,2] <- as.character(activityLabels[,2])

features <- read.table("UCI HAR Dataset/features.txt")
str(features)
features[,2] <- as.character(features[,2])

featuresWanted <- grep(".*mean.*|.*std.*", features[,2])
featuresWanted
featuresWanted.names <- features[featuresWanted,2]
featuresWanted.names = gsub('-mean', 'Mean', featuresWanted.names)
featuresWanted.names = gsub('-std', 'Std', featuresWanted.names)
featuresWanted.names <- gsub('[-()]', '', featuresWanted.names)
featuresWanted.names

train <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresWanted]
train
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")

train <- cbind(trainSubjects, trainActivities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresWanted]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")

test <- cbind(testSubjects, testActivities, test)

CombinedData <- rbind(train, test)
names(CombinedData)
colnames(CombinedData) <- c("subject", "activity", featuresWanted.names)

head(CombinedData)
CombinedData$activity <- factor(CombinedData$activity, 
                                levels = activityLabels[,1], 
                                labels = activityLabels[,2])

CombinedData$subject <- as.factor(CombinedData$subject)

library(reshape2)

CombinedData.melted <- melt(CombinedData, id = c("subject", "activity"))

CombinedData.mean <- dcast(CombinedData.melted, 
                           subject + activity ~ variable, mean)
CombinedData
write.table(CombinedData.mean, file = "TidyDataSet.txt", 
            row.names = FALSE, quote = FALSE)

