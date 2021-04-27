# 6. JOINING MULTIPLE DATA.TABLES

# Load packages:
library(data.table)

# 6.1 Joining data.tables ####
# A join describes the action of combining information from two different data.tables into a single data.table. This is a fundamental skill when working with multiple data sources. The majority of R's functions for analyzing and visualizing data are designed to work on a single data.frame or data.table. But often the data is spread across multiple datasets, that may come from different sources.
# Load the "netflix" dataset which contains information about some of the Netflix original series released in 2017:
netflix <- as.data.table(read.csv("netflix_2017.csv"))
# Load the "imdb" dataset which contains ratings for some TV shows and movies obtained from IMDB:
imdb <- as.data.table(read.csv("imdb_ratings.csv"))
# The tables() dunction shows all the tables in R session, along with their number of rows, their number and names of their columns, and how much space they occupy in term of memory.
tables()
# First we need to identify the join key columns. These are columns in each data.table to match the rows between them for a join. To identify join keys, inspect the contents of the data.table:
head(netflix, 6)
head(imdb, 6)
# The str() is a general purpose function which shows the type of each column in any R object:
str(netflix)
str(imdb)
# "title" column in both netflix and imdb can be used to match the rows across the two data.tables.

# 6.2 merge function ####
# Four standard joins are: inner join, left join, right join, and full join. Each of these joins give a different result, based on what observation are present in one data.table but not in the other. All four are standard joins that originally come from database query language, such as SQL, so the concepts and skills for data.table are widely applicable, not just in R. 
# An inner join combines the columns of two tables, keeping only the observations available, that is, rows whose value in the join key column can be found in each data.table. An inner join is the default behavior of the merge(). It takes 2 data.tables as inputs (x, y, by.x = "key", by.y = "key"). When the key column has the same name in both data.tables, use by = "key" instead.
merge(netflix, imdb, 
      by = "title")
# A full join keeps all the observations that are in either data.table:
merge(netflix, imdb, 
      by = "title", all = TRUE)
# Observations which are present only one data.table will have missing values.
# Left join add the information from the right data.table to the left data.table. This is especially helpful when you have information from different sources, but only need one.
merge(netflix, imdb, by = "title", all.x = TRUE) # missing information for observations that are not present in the right table of the join contain NAs for the right data.table's columns.
# Conversely, a right join keeps only the observations that are present on the data.table on the right side of the join. 
merge(netflix, imdb, all.y = TRUE)
# Right joins and left joins are essentially the same, with the order of input data.tables swapped in the join.
merge(imdb, netflix, all.x = TRUE)
# The outcome is the same as swapping the order of the data.tables in merge() and performing a left join. 
# Default values for "all", "all.x" and "all.y" are FALSE in the merge()

# 6.3 Simple joins ####
# Load three data.tables which contain information about the geography and population of Australia:
area <- as.data.table(read.csv("australia_area.csv"))
population <- as.data.table(read.csv("australia_cities_top20.csv"))
capitals <- as.data.table(read.csv("australia_capitals.csv"))
# Check if the data.tables are loaded:
tables()
# Identify key and join capitals and population:
capital_pop <- merge(capitals, population, by = "city", all.x = TRUE)
capital_pop
# Identify key and join area to capital_pop:
australia_stats <- merge(capital_pop, area, by = "state")
australia_stats