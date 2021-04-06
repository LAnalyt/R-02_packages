# 3. GROUPWISE OPERATIONS

# Load packages and datasets:
library(data.table)
library(bikeshare14)
data(batrips)
batrips <- as.data.table(batrips)

# 3.1 Computation by groups ####
# Most data wrangling tasks require doing the same computation on several groups of data. E.g, calculate the total number of trips for each start_station with the "by" argument in data.table:
batrips[, .N, by = "start_station"]
# The expression in j argument is computed for each group. The columns in the resulting data.table are corresponding to the total rows computed using the special symbol ".N" and the column used in "by". The column used by group is always returned as the first column.
# "by" argument accepts both character vector of column names as well as a list of variables/expressions.
batrips[, .N, by = .(start_station)]
# Renaming the grouping columns on the fly:
batrips[, .(no_trips = .N), by = .(start = start_station)]
# The list() or .() expression in "by" allows for grouping variables to be computed on the fly. E.g, get the number of trips for each start_station for each month:
batrips[, .N, by = .(start_station, mon = month(start_date))] # month() from the data.table package extracts month information from a Date object in R.
# With a single line of code, we can compute the total trips for each start_station for each month.
# Computing multiple stats:
batrips[, .(min_duration = min(duration), max_duration = max(duration)), 
        by = .(start_station, end_station, month(start_date))]

# 3.2 Chaining expressions ####
# Instead of assigning the output data.table to an intermediate object and then performing some operation on it, you can successively perform operations on the outputs. E.g, find the three shortest trips that are over 1 hour:
step_1 <- batrips[duration > 3600] # 1 hour = 3600 seconds.
step_2 <- step_1[duration > 3500][order(duration)]
step_2[1:3]
# This can be written with chaining expressions:
batrips[duration > 3600][order(duration)][1:3]
# Suppose you want to find the top three start stations which have the lowest mean duration. This task requires several steps:
step_1 <- batrips[, .(mn_dur = mean(duration)),
                   by = "start_station"]
step_2 <- step_1[order(mn_dur)]
step_2[1:3]
# Instead, we can do all this in a single step without using temporary variables.
batrips[, .(mn_dur = mean(duration)),
         by = "start_station"][order(mn_dur)][1:3]

# uniqueN(): a help function that returns an integer value containing the number of unique values in the input object. It accepts vectors as well as data.frame and data.table.
id <- c(1, 2, 2, 1)
uniqueN(id)
x <- data.table(id, val = 1:4)
uniqueN(x) # results 4, since there are no duplicate rows.
# Use the "by" argument in uniqueN() to search for the number of unique values in a specific column of a data.table:
uniqueN(x, by = "id") # results 2, as the id column consists of only 2 unique values.

# 3.3 Computing in j using .SD ####
# .SD: stands for "Subset of Data" is a powerful symbol in data.table which enables to do complex data wrangling in a straightforward manner.
# When grouping, .SD holds the intermediate data corresponding to each group while results for that group are being computed. It contains all the columns except the grouping column itself, by default.
x <- data.table(id = c(1, 1, 2, 2, 1, 1),
                val1 = 1:6, val2 = letters[6:1])
x
x[, print(.SD), by = id] # .SD contains "val1" and "val2" columns for each unique value of id. 
# The subset is a data.table, which means we can perform subsets, selects, computations within each group.
# Use .SD to find the first row for each id:
x[, .SD[1], by = id]
# Calculate the number of unique bike ids for every month:
batrips[, uniqueN(bike_id), 
        by = month(start_date)]
# Combine .SD with .N to obtain the last row for each unique id:
x[, .SD[.N], by = id]
# .SD[1] and .SD[.N] return the first and last row for each id. However, it returns all the columns "val1" and "val2". .SDcols controls the columns that should be included in .SD. .SDcols takes a character vector of column names that decides the columns to be included.
batrips[, .SD[1], by = start_station,
        .SDcols = c("trip_id", "duration")]
# Prefix the character vector in .SDcols with a negative sign "-" or the NOT operator "!" to return all the columns except the ones provided to .SDcols.
batrips[, .SD[1], by = start_station,
        .SDcols = !c("trip_id", "duration")]
# Find the row corresponding to the shortest trip for each month:
relevant_cols <- c("start_station", "end_station", "start_date", "end_date", "duration")
batrips[, .SD[which.min(duration)], by = month(start_date), 
        .SDcols = relevant_cols]
# Find the total number of unique start_stations and zip codes for each month: 
batrips[, lapply(.SD, uniqueN), by = month(start_date), 
        .SDcols = c("start_station", "zip_code")]