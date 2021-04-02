# INTRODUCTION TO DATA.TABLE

# The `data.table` package provides a high-performance version of base R's data.frame with syntax and feature enhancements for ease of use, convenience and programming speed. 

# 1.1 data.table package ####
# A data.table is also a data.frame but does so much more. Like data.frames, they are columnar data structures and all columns must be of equal length. 
# Most data analysis tasks require performing operations by groups. Group can be considered as the virtual third dimension. The data structure of data.table is powerful because it provides quick access to these dimensions in the form of placeholders for operations on rows, columns, and groups.
# DT[i, j, by]
# i: on which row
# j: what to do?
# by: grouped by what?
# data.table is very fast: many operations are paralleled: filtering, ordering, grouping, file reading, writing...etc.
# data.table also has many additional powerful features: parallelization, fast updates by reference, powerful joins...etc
install.packages("data.table")
library(data.table)

# 1.2 Creating a data.table ####
# There are at least 3 ways to create a data.table.
# Create a data.table from scratch with data.table() like data.frame():
x_df <- data.frame(id = 1:2,
                   name = c("a", "b"))
x_dt <- data.table(id = 1:2, 
                   name = c("a", "b"))
# To convert an existing R object to a data.table, use as.data.table():
y <- list(id = 1:2,
          name = c("a", "b"))
y
x <- as.data.table(y)
x # the list y is converted to a data.table.
# Confirm if x is a data.table:
class(x)
# Thus you can use all the functions for data frame to a data.table, e.g to return number of rows, columns and the dimension of the data frame.
nrow(x)
ncol(x)
dim(X)
# Unlike a data.frame, a data.table does not convert automatically characters to factors, thus, preventing bugs by avoiding unexpected behavior. Also, a data.table never sets or uses the row names. When you print a data.table, a ":" is added after the row number to separate it from the first column.

# 1.3 bikeshare14 package ####
# We will use the batrips dataset from the bikeshare4 package, which contains anonymous bike share data on bicycle trips around San Francisco in 2014. 
# Install and load the package with the dataset: 
install.packages("bikeshare14")
library(bikeshare14)
data(batrips)
# Examine the batrips dataset:
str(batrips)
head(batrips, 5)
tail(batrips, 5)
# Convert batrips to a data.table:
batrips <- as.data.table(batrips)
class(batrips)

# 1.4 Filtering rows ####
# The general form of a data.table is DT[i, j, by] where i is used to subset or filter rows. The functionality is similar to data.frames but more convenient and enhanced. Rows can be filtered using row number like in data.frame, except that the first argument is always interpreted as a row operation irrespective of whether or not you specify a comma.
# E.g, subset 3rd and 4th rows from batrips:
batrips[3:4]
batrips[3:4, ] # returns the same result.
# data.table contains a few handy special symbols (or variables) that make many operations efficient.
# Filtering rows using negative integers:
batrips[-(1:2)] # select all rows except the first two.
# or using negative operator:
batrips[!(1:2)]
# Select all rows except 1 through 5 and 10 through 15:
batrips[!c(1:5, 10:15)]
# .N: an integer vector of length one. When used in the i argument, it returns the total number of rows in the data.table. To get the last rows, simply pass:
batrips[.N]
# Alternative with nrow():
batrips[nrow(batrips)]
# Get all the rows except the last 10 rows:
batrips[1:(.N - 10)]
# Since .N is the total number of rows, you're essentially creating a continuous sequence of integers from 1 to the required row number.

# Construct expressions resulting in a logical vector in the i argument:
batrips[subscription_type == "Subscriber"] # returns only rows that evaluate to TRUE.
# Compare to the syntax of the equivalent data.frame:
batrips[batrips$subscription_type == "Subscriber", ]
# Within the scope of data.table, columns are seen as variables. This avoids unnecessary repetition of the $ sign when referring to column names. 
# Filter for rows combining relational operators:
batrips[start_terminal == 58 & end_terminal != 65]
# Compare with the data.frame code:
batrips[batrips$start_terminal == 58 & batrips$end_station != 65]
# We see the data.table syntax is concise and clear.

# 1.5 Helpers for filtering ####
# A commonly occurring subsetting operation is to look for all rows that match a pattern in a column. %like% in data.table allows you to search for a pattern in a character or a vector.
# Look for all the rows where start_station starts with San Francisco:
batrips[start_station %like% "^San Francisco"]
# The meta-character "^" specifies that you are looking for a pattern at the beginning of a string. Alternatively with grepl() for searching patterns:
batrips[grepl("^San Francisco", start_station)]

# %between% is helper function that works on numeric columns. It searches for all values in the closed interval [val1, val2]. E.g, subset all rows where duration is between 2000 and 3000:
batrips[duration %between% c(2000, 3000)]
# Alternatively:
batrips[duration >= 2000 & duration <= 3000]

# %in% allows selecting rows that exactly matches one or more values. E.g, Filter all rows where trip_id is equal to 588841, 139560, or 139562:
batrips[trip_id %in% c(588841, 139560, 139562)]
# %chin% is similar to %in%, but it is much faster and only for character vectors. E.g, subset all rows where start_station is "Japantown", "Mezes Park" or "MLK Library":
batrips[start_station %chin% c("Japantown", "Mezes Park", "MLK Library")]