# 2. COMPUTING ON COLUMNS

# Just as the i argument lets you filter rows, the j argument of data.table lets you select columns and also perform computations. The syntax is far more convenient and flexible when compared to data.frames.  
# Load packages and datasets:
library(data.table)
library(bikeshare14)
data(batrips)
batrips <- as.data.table(batrips)

# 2.1 Selecting column ####
# Similarly to data.frame, you can pass a character vector of column names to select the relevant columns.
ans <- batrips[, "trip_id"]
head(ans, 2)
class(ans)
# The different in the result is selection columns in data.table returns a data.table whereas data.frame results a vector. This consistency in the output avoids accidental errors in code. 
# Select columns using column numbers:
batrips[ , c(2, 4)]
# However, using column numbers is a bad practice except when having a quick look at the data interactively. An inadvertent change to the original column structure can lead to incorrect results and bugs.
# Deselecting columns with "-" or "!" sign prefix to exclude a set of columns from the result:
ans <- batrips[, !c("start_date", "end_date", "end_station")]
head(ans, 1)
# The data.frame approach in data.table limits in selecting columns only. In order to compute on columns and perform advanced data manipulations, we will need to use the data.table approach. For j argument, we can refer to columns directly as if they are variables. Since we often need to select more than one column, j accepts a list of column. 
ans <- batrips[, list(trip_id, dur = duration)]
# Wrapping the column name within list() always returns a data.table.
class(ans)
# When selecting a single column without wrapping the variable by list() returns a vector.
ans <- batrips[, trip_id]
is.vector(ans)
# .() is also an alias to list() as one concise way of writing code.
ans <- batrips[ , .(trip_id, duration)]
head(ans, 2)

# 2.2 Compute columns ####
# Since columns can be referred to as variables, we can compute directly. E.g, compute the average duration:
batrips[, mean(duration)] # returns a vector, since it's not in list().
# Compute this in the data.frame way:
mean(batrips[, "duration"])
# The data.table way of computing directly on columns allows for clear, convenient and concise code and can be easily extended to calculate statistics on multiple columns.
# Combining i and j to compute the mean of duration for trips from "Japan town":
batrips[start_station == "Japantown", mean(duration)]
# This computation is possible because j is computed on the rows returned by the filtering operation.
# The special symbol ".N" which holds the number of rows in a data.table is also useful in j, e.g, to calculate the number of trips started from Japan town.
batrips[start_station == "Japantown", .N]
# Since j is calculated on the result of i, we get the total number of rows in filtered data.table.
# Compare this to the equivalent process on data.frame:
nrow(batrips[batrips$start_station == "Japantown", ]) # first returns all the columns for the filtered data only to compute the total of number of rows.
# Find the median duration where end_station is "Market at 10th" for all subscribers:
batrips[end_station == "Market at 10th" & subscription_type == "Subscriber", median(duration)]
# Use difftime() to calculate the difference in minutes between the trips:
trip_duration <- batrips[, difftime(end_date, start_date, units = "min")]
head(trip_duration)

# 2.3 Advanced computations
# Compute on multiple columns with .(), e.g, get the mean and median of duration:
batrips[, .(mn_dur = mean(duration),
             med_dur = median(duration))]
# Get the min and max duration values without renaming the columns:
batrips[, .(min(duration), max(duration))]
# Calculate the average duration and the date of the last ride:
batrips[, .(mean_duration = mean(duration), 
            last_ride = max(end_date))]
# Combine with i to compute on the columns in j only for the rows that satisfy a condition:
batrips[start_station == "Japantown", .(mn_dur = mean(duration),
                                        med_dur = median(duration))]
# Calculate the minimum and maximum duration for all trips where the start_station is "Townsend at 7th" and the duration is less than 500:
batrips[start_station == "Townsend at 7th" & duration < 500,
        .(min_dur = min(duration),
          max_dur = max(duration))]
# Additionally, you can also specify plot(), hist() or any other plotting functions in the j argument.
batrips[start_station == "Townsend at 7th" & duration < 500,
        hist(duration)]