# 7. JOINS USING DATA.TABLE SYNTAX

# Load packages:
library(data.table)
# Load three data.tables which contain information about the geography and population of Australia:
area <- as.data.table(read.csv("australia_area.csv"))
population <- as.data.table(read.csv("australia_cities_top20.csv"))
capitals <- as.data.table(read.csv("australia_capitals.csv"))
# Load the two datasets "netflix" and "imdb" which contains information about some of the Netflix original series released in 2017:
netflix <- as.data.table(read.csv("netflix_2017.csv"))
imdb <- as.data.table(read.csv("imdb_ratings.csv"))

# 7.1 Joining using data.table syntax ####
# General form of data.table syntax join: DT[i, on]
# # Join key columns are supplied to the "on" argument. This follows similar rules to the "j" and "by" arguments in the data.table syntax. Right join population to capitals:
capitals[population, on = list(city)]
# Or use the "." indicator:
capitals[population, on = .(city)]
# Or using a character vector to specify the join key:
join_key = c("city")
capitals[population, on = join_key]
# To compare the output, right join population to capitals using the merge() function:
merge(capitals, population, by = "city", all.y = TRUE)
# The row ordering is different in the results. This is because joins using the data.table syntax treat the i argument like a subset operation, so it returns rows in the order they appear in the data.table given to the i argument, while the merge() function sorts rows based on the values in the key column.
# To perform a left join you can swap the order of the data.tables:
population[capitals, on = .(city)]
# Perform an inner join, etaining rows only from both the tables:
capitals[population, on = .(city), nomatch = 0] 
# The argument "nomatch" tells the data.table syntax to ignore rows that cannot be matchted between the two data.tables.If you are performing many inner joins, you can change the default behaviour of nomatch by setting options(datatable.nomatch = 0) in your R session.
# Anti-joins are a useful way of identifying rows that have no match in another data.table.
population[!capitals, on =.(city)]
area[!capitals, on =.(state)]
# It's not possible to perform a full join with the data.table syntax.

# 7.2 Setting data.table keys ####
# Setting keys means you don't need the "on" argument when performing a join. This is useful if you need to use a data.table in many different joins. Setting a key will also sort the data.table by that column in memory, which makes joining and filtering operations on that columns much faster for large data.tables. You can also set multiple key columns for a single data.table. The setkey() function takes a single data.table as its first argument, then any number of key column names as its remaining arguments.
setkey(netflix, title)
# Wrapping the variable name in "" also works:
setkey(imdb, "title")
# When keys are set for two data.tables, you can use the data.table syntax without the "on" argument for performing joins.
netflix[imdb, nomatch = 0]
# Using setkey() will also sort the rows of a data.table by the key columns. This makes joins and filter operations on the keys more efficient, and can be much faster for large data.tables.
# If you don't provide any column names to the setkey() function, it will use all columns of the data as its key!
setkey(netflix)
setkey(imdb)
netflix[imdb, nomatch = 0]

# Check whether a data.table has any key column set:
haskey(netflix)
# key() returns the key columns you have set.
key(imdb)  
the_key <- key(netflix)
# setkeyv(): sets the key of a data.table by passing in a character vector of the key column names. This is useful if you want to set the keys of a data.table programmatically, where your column names are stored in another variable.
setkeyv(imdb, the_key)
# The key() function is a useful way of reducing typing errors that can happen when manually typing long keys or multiple keys over and over again. This can be used together with the haskey() and setkeyv() functions for programmatic key checking and setting.
# View all tables with their keys:
tables()

# 7.4 Incorporating joins into data.table workflow ####
# The real power of perorming joins with data.table syntax is that it allows you to incorporate joins into your other data.table workflows. This enables you to perform rapid data analysis when your data is spread across multiple data.tables. 
# The most flexible way of incorporating joins into your data.table workflows is by chaining data.table expressions. General form of chaning a join: DT1[DT2, on][i, j, by]. E.g, join then compute the two data.tables of customers and their purchase history:
customers <- data.table(name = c("Mark", "Matt", "Angela", "Michelle"),
                        gender = c("M", "M", "F", "F"),
                        age = c(54, 43, 39, 63))
purchases <- data.table(name = c("Mark", "Matt", "Angela", "Michelle"),
                        sales = c(1, 5, 4, 3),
                        spent = c(41.70, 41.78, 50.77, 60.01))
customers[purchases, 
          on = .(name)][sales > 1, 
                        j = .(avg_spent = sum(spent) / sum(sales)),
                        by = .(gender)]
# This is a memory efficient way to perform calculations on the result of a join because the data.table expression will create only the join result for the columns used in j in memory. 
# Computation with joins: DT1[DT2, on, j]. E.g, compute based on the sales column from the purchases data.table:
customers[purchases, on = .(name), return_customer := sales > 1]
# Calculate the total percentage of people living in major cities of Australia by joining and summing the two capitals and population data.tables:
capitals[population, on = .(city), nomatch = 0,     # inner join
         j = sum(percentage)]                     
# The "by" argument gains a special symbol, ".EACHI", when used in a join expression. This lets you group computation in j by each row in the data.table on the right side of the join: DT1[DT2, on, j, by = .EACHI].
# Load the dataset which contains the life expectancy of each country in 2010 sourced from the Gapminder Foundation.
life_exp <- as.data.table(read.csv("gapminder_life_expectancy_2010.csv"))
# Load the dataset which contains a mapping between each country and the continents they are part of built from information provided by Countries-ofthe-World.com.
continents <- data.table(read.csv("continents.csv"))
# Build a data.table containing the number of matches in continents for each row in life_exp and filter the result to contain just countries with more than one match:
continents[life_exp, on = .(country), .N,
           by = .EACHI][N > 1]
# Calculate average life expectancy per continent:
continents[life_exp, on = .(country), 
           nomatch = 0][, j = mean(life_expectancy),
                        by = continent]