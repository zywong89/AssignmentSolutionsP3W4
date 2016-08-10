rm(list = ls())
setwd("~")
setwd(paste0("Desktop/Coursera/Data Science/P3 Getting and Cleaning Data/",
      "Week 4 Text and Date Manipulation/Course Project/UCI HAR Dataset"))
library(plyr)
library(dplyr)

# Item 1
# Loads training set data
subject_train <- rename(read.table("train/subject_train.txt"), subject = V1)
X_train <- read.table("train/X_train.txt")
Y_train <- rename(read.table("train/Y_train.txt"), activity = V1)
trainDF <- as.data.frame(cbind(subject_train, Y_train, X_train))
# Loads test set data
subject_test <- rename(read.table("test/subject_test.txt"), subject = V1)
X_test <- read.table("test/X_test.txt")
Y_test <- rename(read.table("test/Y_test.txt"), activity = V1)
testDF <- as.data.frame(cbind(subject_test, Y_test, X_test))
# Merge the training and test sets
fullSet <- rbind(trainDF, testDF)

# Item 2
# Loads the list of all features
features <- read.table("features.txt")[, 2]
# Extracts only measurements on the mean and standard deviation.
# The first two columns are subject and activity label.
# Hence, they are excluded from evaluation.
fullSet <- fullSet[, c(1:2, grep(".*[Mm]ean|.*std", features) + 2)]

# Item 3
# Loads the list of activity labels
activities <- rename(read.table("activity_labels.txt"), activity = V1, label = V2)
# Finds the activity labels and substitute the column
fullSet <- select(join(fullSet, activities), c(1, label, 3:(ncol(fullSet))))

# Item 4
# Graps all features that involve measurements on the mean and standard deviation.
features <- features[grep(".*[Mm]ean|.*std", features)]
# Removes dashes, commas and brackets
features <- gsub("-", "", features)
features <- gsub(",", "", features)
features <- gsub("\\(", "", features)
features <- gsub("\\)", "", features)
# Except for the first word, the subsequent words should begin with a capital letter.
features <- gsub("mean", "Mean", features)
features <- gsub("std", "StdDev", features)
features <- gsub("gravity", "Gravity", features)
features <- gsub("BodyBody", "Body", features)
# Rename the variables in the merged data set.
colnames(fullSet)[3: ncol(fullSet)] <- features

# Item 5
# From the data set in step 4, creates a second, 
# independent tidy data set with the average of each variable for each activity and each subject.
library(reshape2)
fullSetMelted <- melt(fullSet, id = c("subject", "label"), measure.vars = features)
newSet <- dcast(fullSetMelted, subject + label ~ variable, mean)
write.table(newSet, file = "tidyDataSet.txt")
