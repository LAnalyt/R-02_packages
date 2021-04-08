# 4. REFERENCE SEMANTICS

# Load packages and datasets:
library(data.table)
library(bikeshare14)
data(batrips)
batrips <- as.data.table(batrips)

# 4.1 Adding and updating columns by reference ####
# Reference semantics is a unique feature of data.table, which enables you to add, update and delete columns of data in place.
df <- data.frame(x = 1:5, y = 6:10)
df
# Suppose you want to change one element of the data.frame:
df$y[2] <- 10
# In older R version than v3.10, this operation resulted in deep copying the entire data.frame. The entire df data.frame was copied in memory to a completely different location and assigned a temporary variable name, e.g, tmp. The new value was updated on tmp and the result was then assigned back to df.
tmps <- <deep copy of "df">
tmp$y <- 10
df <- tmp
# If the data.frame is 10 Gb, you will need extra 10 Gb memory just to replace a single value of a single column!
# v3.10 improvement: deep copy only the column that is updated. 
df <- data.frame(a = 1:3, 
                 b = 4:6,
                 c = 7:9,
                 d = 10:12)
df[1:2] <- lapply(df[1:2], function(x) ifelse(x %% 2, x, NA))
df
# If you want too replace all even values, from v3.10, only columns a and b are deep copied instead of the entire data.frame. However, the columns being updated are still being deep copied. 
# data.table does not deep copy objects or create any temporary variables. It simply updates the original data.table in place, i.e, by reference. Since the original data.table is directly updated, there is no need to assign the result back to a variable. Therefore it is extremely fast and memory efficient.  
# ":=" operator in data.table: add/update/delete columns by reference.
batrips[, c("is_dur_gt_1hour", "week_day") := list(duration > 3600,
                                                   wday(start_date))]
head(batrips, 5) # two columns are added to the original data.table.
# When adding a single column, quotes aren't necessary for character vector.
batrips[, is_dur_gt_1hour := duration > 3600] # new column showing if the trip is longer than 1 hour or not.
# The other way of using ":=" operator is the functional form. It takes the form: "col1 = val1", "col2 = val2" etc.
batrips[, `:=`(is_dur_gt_1hour = NULL, # deletes the column by reference.
               start_station = toupper(start_station))] # change the name of start_station to upper case.
# Add a new column duration_hour that computes duration in hours:
batrips[, duration_hour := duration/3600]
head(batrips, 5) # no need to assign the result to any object. The new column is simply added to the existing data.table. 

# 4.3 Grouped aggregations ####
# Suppose you want to filter the batrips data that contain only zip codes with greater than 1000 trips. You will need to add and update columns for different groups in the data.table using the "by" argument.
batrips[, n_zip_code := .N, by = zip_code]
ncol(batrips) # new column n_zip_trip is added, which contains the total trips made for each zip_code.
# Updating by reference in data.table is not shown in the console. To view the result as soon as you update a data.table by reference, chain a []:
batrips[, n_zip_code := .N, by = zip_code][]
# Now filter the n_zip_code for zip_code with greater than 1000 trips:
batrips[n_zip_code > 1000]
# Delete the n_zip_code in the final result by chaining one more expression:
zip_1000 <- batrips[, n_zip_code := .N, 
                    by = zip_code][n_zip_code > 1000][, n_zip_code := NULL]
# This a very common pattern in data analysis. You often need to add intermediate columns to get to the final result, but don't necessarily need them for the final results.
# Add a new column by reference called trips_N that is equal to the total number of trips for every start_station:
batrips[, trips_N := .N, by = start_station][]
# Add a new column by reference called duration_mean that is equal to the mean duration of trips for each unique combination of start_station and end_station:
batrips[, duration_mean := mean(duration), 
        by = c("start_station", "end_station")][]
# Add a new column mean_dur by reference that is the mean duration of all trips grouped by month (based on start_date). Note that duration column has missing values.
batrips[, mean_dur := mean(duration, na.rm = TRUE),
        by = month(start_date)][]
# Chain a new data.table expression that replaces all missing values in duration with the corresponding mean_dur value:
batrips[, mean_dur := mean(duration, na.rm = TRUE),
        by = month(start_date)][is.na(duration), duration := mean_dur][]
# Finally, delete the mean_dur column by reference:
batrips[, mean_dur := mean(duration, na.rm = TRUE),
        by = month(start_date)][is.na(duration), duration := mean_dur][, mean_dur := NULL][]

# 4.4 Advanced aggregations ####
# Adding multiple columns by reference by group:
batrips[, c("end_dur_first", "end_dur_last") := list(duration[1], duration[.N]), by = end_station][]
# Same result using functional form:
batrips[, `:=`(end_dur_first = duration[1],
               end_dur_last = duration[.N]),
        by = end_station][]
# Add two new columns by reference that calculates the mean and median of the duration column for every start_station:
batrips[, c("mean_duration", "median_duration") := .(mean(duration), median(duration)), by = start_station][]
# Same result with functional form:
batrips[, `:=`(mean_duration = mean(duration),
               median_duration = median(duration)),
        by = start_station][]
# For all rows where duration is greater than 600, group batrips by start_station and end_station to add a new column (mean_duration) by reference which calculates the mean duration of all trips:
batrips[duration > 600, mean_duration := mean(duration),
        by = c("start_station", "end_station")][]
# Create a new column based on each unique combination of start_station and end_station:
# "short": less than 600
# "medium": between 600 and 800
# "long": otherwise
# Use if-else statements to accomplish this:
batrips[, trip_category := {
        med_dur = median(duration, nar.rm = TRUE)
        if (med_dur < 600) "short"
        else if (med_dur >= 600 & med_dur <= 1800) "medium"
        else "long"
        }, 
        by = .(start_station, end_station)]
batrips[1:3]
# The j argument can handle complex multi-line expressions. Alternatively, you can create a user-defined function to accomplish the same task.
bin_median_duration <- function(dur) {
        med_dur <- median(dur, na.rm = TRUE)
        if (med_dur < 600) "short"
        else if (med_dur >= 600 & med_dur <= 1800) "medium"
        else "long"
}
batrips[, trip_category := bin_median_duration(duration),
        by = .(start_station, end_station)][]
# Combine all three argumenst "i", "j" and "by" together:
batrips[duration > 500, min_dur_gt_500 := min(duration), 
        by = .(start_station, end_station)][]
# data.table first evaluates the expression in "i", which returns all the rows where duration is greater than 500. On those rows, the "by" argument is applied by creating groups for each unique combination of start_station and end_station. Finally, for each of those groups the expressions in "j" is evaluated. We thereby obtain the smallest duration greater than 500 for each specified group. If all values for a particular group are less than 500, there are no rows to group by, which would result in NA.