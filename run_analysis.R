## Install the packages and load the libraries
install.packages("data.table", "dplyr", "tidyr") #If necessary
library(data.table)
library(dplyr)
library(tidyr)

## Merge the training and test datasets to create one dataset.

# Download and open the zip file.
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
              destfile = "run.zip")
unzip("run.zip")

# Download and read the relevant files
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt",
                              sep = " ",
                              col.names = c("activity_index", "activity_name"))
features <- read.table("./UCI HAR Dataset/features.txt",
                       sep = " ",
                       col.names = c("feature_number", "feature_name"))
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt",
                           col.names = "subject",
                           colClasses = "character")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt",
                     sep = " ",
                     header = FALSE,
                     colClasses = "character",
                     col.names = "activity")
x_test <- read.fwf("./UCI HAR Dataset/test/X_test.txt",
                   widths = rep(16, each = 561),
                   header = FALSE,
                   col.names = features$feature_name,
                   colClasses = "numeric")
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt",
                            col.names = "subject",
                            colClasses = "character")
y_train <- read.delim("./UCI HAR Dataset/train/y_train.txt",
                      sep = " ",
                      header = FALSE,
                      colClasses = "character",
                      col.names = "activity")
x_train <- read.fwf("./UCI HAR Dataset/train/X_train.txt",
                    widths = rep(16, each = 561),
                    header = FALSE,
                    col.names = features$feature_name,
                    colClasses = "numeric")

# Merge the test datasets with each other and the training datasets with each other.
#	Also adds the subject and activity numbers to each dataset.
test_complete <- cbind(subject_test, y_test, x_test)
train_complete <- cbind(subject_train, y_train, x_train)

# Merge the test and training files together.
complete <- rbind(test_complete, train_complete)

# Add the activity name.
for(i in 1:6) {
        complete$activity[complete$activity == i] <- activity_labels$activity_name[i]}


## Extract the measurements of mean and standard deviation for each measurement
#	Excludes meanFreq.
complete_names <- names(complete)
complete_names_not_freq_index <- as.vector(grepl(pattern = "(meanFreq)",
                                                 x = complete_names,
                                                 ignore.case = FALSE))
complete_names_not_freq <- select(complete,
                                  names(complete[!complete_names_not_freq_index]))
complete_names_mean_std_index <- as.vector(grepl(pattern = "(mean|std|subject|activity)",
                                                 x = names(complete_names_not_freq),
                                                 ignore.case = FALSE))
# This is the final merged dataset with just the means and standard deviations.
run_merged_data <- select(complete_names_not_freq,
                      names(complete_names_not_freq[,complete_names_mean_std_index]))


## Create a tidy dataset with the average of each variable for each activity and subject.
run_means_index <- grepl(pattern = "(mean|subject|activity)",
                        x = names(run_merged_data))
run_merged_means <- select(run_merged_data,
                   names(run_merged_data[run_means_index]))
run_melt <- melt(data = as.data.table(run_merged_means),
                 id.vars = c("subject", "activity"),
                 variable.name = "measurement",
                 value.name = "mean")
#This is the final dataset with just the means for each subject, activity, and measurement.
run_tidy_data <- group_by(run_melt, subject, activity, measurement) %>%
        summarize(mean_of_means = mean(mean))
# Remove all data except the merged (merged_data) and tidy (run_tidy_data) datasets.
rm(activity_labels, complete, complete_names, features, run_melt, run_merged_means,
   subject_test, subject_train, test_complete, train_complete, x_test, x_train,
   y_test, y_train, complete_names_not_freq, complete_names_mean_std_index,
   complete_names_not_freq_index, i, run_means_index)
