### GOAL
*Below description is taken from Coursera:*     
The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. You will be graded by your peers on a series of yes/no questions related to the project. You will be required to submit: 1) a tidy data set as described below, 2) a link to a Github repository with your script for performing the analysis, and 3) a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md. You should also include a README.md in the repo with your scripts. This repo explains how all of the scripts work and how they are connected.

One of the most exciting areas in all of data science right now is wearable computing - see for example this article . Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained:

| (http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones)

Here are the data for the project:

| (https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip)

You should create one R script called run_analysis.R that does the following.
1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement.
3. Uses descriptive activity names to name the activities in the data set4
4. Appropriately labels the data set with descriptive variable names.
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.


### DATA
*Below description is taken from the documentation of the dataset:*     
The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments have been video-recorded to label the data manually. The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data.     

The sensor signals (accelerometer and gyroscope) were pre-processed by applying noise filters and then sampled in fixed-width sliding windows of 2.56 sec and 50% overlap (128 readings/window). The sensor acceleration signal, which has gravitational and body motion components, was separated using a Butterworth low-pass filter into body acceleration and gravity. The gravitational force is assumed to have only low frequency components, therefore a filter with 0.3 Hz cutoff frequency was used. From each window, a vector of features was obtained by calculating variables from the time and frequency domain. See 'features_info.txt' for more details.     

For each record it is provided:   
- An identifier of the subject who carried out the experiment.     
- Its activity label.     
- A 561-feature vector with time and frequency domain variables.     


### PROCESS
1. Download the data and extract it.     

```{r eval=FALSE}
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, destfile="data.zip")
unzip("data.zip")
list.files(recursive=TRUE)
```

2. Import the **activity_labels.txt** onto the *activityLabels* data frame. Then, rename the column names to *ActivityCode* and *Activity*.     

```{r eval=FALSE}
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
colnames(activityLabels) <- c("ActivityCode", "Activity")
```

3. Convert the first column of activityLabels to a numeric data type.

```{r eval=FALSE}
activityLabels[,1] <- as.numeric(activityLabels[,1])
```

4. Import the **features.txt** onto the *features* data frame. Then, rename the column names to *FeaturesCode* and *Features*.

```{r eval=FALSE}
features <- read.table("UCI HAR Dataset/features.txt")
colnames(features) <- c("FeaturesCode", "Features")
```

5. Consolidate the **subject_test.txt**, **X_test.txt**, and **y_test.txt** onto the *test_data* data frame. Note to consolidate in the order of the files specified.     

```{r eval=FALSE}
test_files <- list.files("UCI HAR Dataset/test", full.names=TRUE)
test_files <- test_files[!grepl("Inertial Signals", test_files)]
test_data <- read.table(test_files[1])
for (i in 2:length(test_files)) {
    test_data <- cbind(test_data, read.table(test_files[i]))
}
```

6. Do the same for the train data sets. Place the data onto the *train_data* data frame.     

```{r eval=FALSE}
train_files <- list.files("UCI HAR Dataset/train", full.names=TRUE)
train_files <- train_files[!grepl("Inertial Signals", train_files)]
train_data <- read.table(train_files[1])
for (i in 2:length(train_files)) {
    train_data <- cbind(train_data, read.table(train_files[i]))
}
```

7. Append the *train_data* onto the *test_data* and store it onto the *combined_data* data frame.     

```{r eval=FALSE}
combined_data <- rbind(test_data, train_data)
```

8. Assign the following column names:     
    + Column 1: *"Subject ID"*     
    + Columns 2-562: Use the second column of *features*     
    + Column 3: *"Activity Performed"*     

```{r eval=FALSE}
colnames(combined_data) <- c("Subject ID", features[,2], "Activity Performed")

```

9. Extract the measurements on the mean and standard deviation together with the *Subject ID* and *Activity* columns.     

```{r eval=FALSE}
mean_std_data <- combined_data[,grepl("[Mm]ean|std|Subject|Activity", colnames(combined_data))]

```

10. Add an additional column to *mean_std_data* named *Activity* where in it is the actual activity performed based from *activityLabels*.     

```{r eval=FALSE}
tidy_data <- merge(mean_std_data, activityLabels, by.x="Activity Performed",
                   by.y="ActivityCode")

```

11. Delete the *Activity Performed* column. Then, reorder the columns in *tidy_data* such that *Subject ID* is the first column and *Activity* is the second column.   
  
```{r eval=FALSE}
tidy_data <- tidy_data[c(2, 89, 3:88)]
```

12. Create another data frame *groupedmean_data* wherein it provides the average of each variable per *Subject ID* and *Activity*.

```{r eval=FALSE}
groupedmean_data <- aggregate(tidy_data, list(tidy_data[,1], tidy_data[,2]), mean, na.rm=TRUE, simplify=TRUE)
groupedmean_data <- groupedmean_data[-c(3,4)]
colnames(groupedmean_data)[1] <- "Subject ID"
colnames(groupedmean_data)[2] <- "Activity"

```

123 Create a text file **output.txt** containing *groupedmean_data*.     

```{r eval=FALSE}
write.table(groupedmean_data, "output.txt")
```