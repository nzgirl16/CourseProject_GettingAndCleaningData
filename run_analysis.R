#Downloading and extracting the data
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, destfile="data.zip")
unzip("data.zip")
list.files(recursive=TRUE)



#Importing the activity_labels.txt and the features.txt
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
colnames(activityLabels) <- c("ActivityCode", "Activity")
activityLabels[,1] <- as.numeric(activityLabels[,1])
features <- read.table("UCI HAR Dataset/features.txt")
colnames(features) <- c("FeaturesCode", "Features")



#Consolidating the test data and the train data into 2 tables
test_files <- list.files("UCI HAR Dataset/test", full.names=TRUE)
test_files <- test_files[!grepl("Inertial Signals", test_files)]
test_data <- read.table(test_files[1])
for (i in 2:length(test_files)) {
    test_data <- cbind(test_data, read.table(test_files[i]))
}   #test_data: df 2947x563
train_files <- list.files("UCI HAR Dataset/train", full.names=TRUE)
train_files <- train_files[!grepl("Inertial Signals", train_files)]
train_data <- read.table(train_files[1])
for (i in 2:length(train_files)) {
    train_data <- cbind(train_data, read.table(train_files[i]))
}   #train_data: df 7352x563



#Merging the training and test data set into one
#Changing the column names based on the features table
combined_data <- rbind(test_data, train_data)
    #combined_data: df 10299x563
colnames(combined_data) <- c("Subject ID", features[,2], "Activity Performed")



#Extracting the measurements on the mean and standard deviation
mean_std_data <- combined_data[,grepl("[Mm]ean|std|Subject|Activity", colnames(combined_data))]
    #mean_std_data: df 10299x88



#Updating the Activity column to be more descriptive
tidy_data <- merge(mean_std_data, activityLabels, by.x="Activity Performed",
                   by.y="ActivityCode")
    #tidy_data: df 10299x89
tidy_data <- tidy_data[c(2, 89, 3:88)]
    #tidy_data: df 10299x88



#Creating another data set with the average of each variable
#for each activity and each subject.
groupedmean_data <- aggregate(tidy_data, list(tidy_data[,1], tidy_data[,2]), mean, na.rm=TRUE, simplify=TRUE)
    #groupedmean_data: df 180x88
groupedmean_data <- groupedmean_data[-c(3,4)]
    #groupedmean_data: df 180x88
colnames(groupedmean_data)[1] <- "Subject ID"
colnames(groupedmean_data)[2] <- "Activity"
write.table(groupedmean_data, "output.txt")
