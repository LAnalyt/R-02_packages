# 5. IMPORTING AND EXPORTING DATA

# Not only does the data.table package help you perform incredibly fast computations, it can also help you read and write data to disk with amazing speeds. 
# Load packages and datasets:
library(data.table)
library(bikeshare14)
data(batrips)
batrips <- as.data.table(batrips)

# 5.1 fread ####
# fread() is a high-performance function of the data.table package for importing files with blazing fast speed. It can import files in parallel on machines where multi-core processors are available. By default, fread() uses all available threads. The number of threads fread() uses can be controlled with nThread argument. 
# fread() from local file:
fread("sample_fread_import.csv")
# fread() from an URL:
fread("https://bit.ly/2RkBXhV")
# fread() from a string:
fread("a,b\n1,2\n3,4")
# fread() automatically detects if it's a file name, an URL or a string. The header is also automatically detected. If there is no header, fread() automatically names them as V1, V2...
fread("1,2\n3,4")
# Use the system.time() to compare the time it takes to read the "batrips.csv" file using read.csv() and fread():
system.time(read.csv("batrips.csv"))
system.time(fread("batrips.csv")) # almost 5x faster!
# Import "sample.csv" using both read.csv() and fread() to compare these functions.
read.csv("sample.csv", fill = NA, quote = "",
         stringsAsFactors = FALSE, strip.white = TRUE, 
         header = TRUE)
fread("sample.csv") # a lot easier by guessing sensibly.
#  Unlike the additional arguments which we provided for read.csv(), fread() could handle importing the file by itself. It can automatically guess column types, skip lines if necessary which useful when reading files that contain comments or metadata, quotes, separators, white space etc.
# fread() has intelligent intuitive arguments as defaults, e.g, importing selected columns using "select" argument:
fread("sample1.csv", select = c("id", "val"))
# Use fread()'s drop argument to drop the "val" column:
fread("sample1.csv", drop = "val")
# "select" and "drop" arguments also take integers as the column number.
fread("sample1.csv", drop = 2)
# "nrow" and "skip" arguments control which rows are imported. "nrows" specifies the total number of rows to read, excluding the header.
fread("sample2.csv", nrows = 4) 
# "nrow" takes an integer as an input. This is particularly useful when you want to have a quick look at the file by reading just some first rows instead of millions of records.
# "skip": also takes an integer as an input and skips that many number of lines before attempting to parse the file. This is useful in handling irregular files, e.g, file with comments or metadata at the beginning of a file.
fread("sample2.csv", skip = 7)
# "skip" can also takes a string as input. It searches for the first exact occurance of that string and parse the file from the line that string occurs.
fread("sample2.csv", skip = "date") # all rows before "date" are skipped.
# Combine "nrows" and "skip" together:
fread("sample2.csv", nrows = 2, skip = "METADATA")

# 5.2 Advanced file reading ####
# R can only represent numbers less than or equal to 2^31 -1 = 2147483647 as type "integer". read.csv() automatically coerces numbers larger than this to numeric type. This might not be appropriate in some cases. data.table sets the type of such columns with large integer values to "integer64" type by default using the bit64 package. 
install.packages("bit64")
library(bit64)
ans <- fread("id, name\n1234567890123, Jane\n5284782381811, John\n")
ans
class(ans$id)
# Whenever possible, you should import your data as integers, especially when the data is big, to save memory in the RAM. 
fread_import <- fread("sample3.csv")
class(fread_import$id)
base_import <- read.csv("sample3.csv")
class(base_import$id)
# It is, however, possible to override the default with numeric or character types if required using colClasses argument.
string <-  "x1,x2,x3,x4,x5\n1,2,1.5,true,cc\n3,4,2.5,false,ff"
ans <- fread(string, colClasses = c(x5 = "factor"))
str(ans)
# colClasses can be a named or unnamed vector of column classes similar to read.csv. If named, column classes are assigned to column names provided before parsing.
ans <- fread(string, colClasses = c("integer", "integer", "numeric", "logical", "factor"))
str(ans)
# In addition, you can also provide a named list of vectors where names correspond to the column names or numbers, and the values correspond the column names or numbers. This is particularly useful when there are too many columns with a limited number of column types.
string <- "x1,x2,x3,x4,x5,x6\n1,2,1.5,2.5,aa,bb\n3,4,5.5,6.5,cc,dd"
ans <- fread(string, colClasses = list(numeric = 1:4, 
                                       factor = c("x5", "x6")))
str(ans)
# When reading files with incomplete columns in a file, it is not always possible to parse them unambiguously. Use "fill" argument to explicitly fill the missing entries:
string <- "1,2\n3,4,a\n5,6\n7,8,b"
ans <- fread(string)
fread(string, fill = TRUE) 
# fread() fills missing values with empty strings. Empty values for integer, lgical and numeric types are filled with NA.
fread("sample4.csv") # the last row is considered a footer and discarded.
fread("sample4.csv", fill = TRUE)
# Not all files encode missing values in the same way, commonly as "999", "##NA", or "N/A". "na.strings" argument takes a character vector of values that are replaced with NA. Since this is done while parsing, it is very memory efficient as well as fast.
string <- "x,y,z\n1,###,3\n2,4,###\n#N/A,7,9"
ans <- fread(str, na.strings = c("###", "#N/A"))
ans

# 5.3 fwrite ####
# Similar to fread(), fwrite() is a fast and paralel file writer. By default, it uses all available threads to write to file.
dt <- data.table(id = c("x", "y", "z"), 
                  val = c(1, 2, 3))
fwrite(dt, "fwrite.csv")
fread("fwrite.csv")
# fwrite() provides intelligent defaults so that in most cases, only the data and the file name arguments are required. It also has the ability to write columns of type "list" by flattening the list column with the secondary separator "|".
dt <- data.table(id = c("x", "y", "z"), 
                 val = list(1:3, 4:6, 7:9))
fwrite(dt, "fwrite1.csv")
fread("fwrite1.csv")
# fwrite() also provides multiple ways to write data and datetime columns using the "dateTimeAs" argument which defaults to the ISO format. This results in representing datetime values in international standard, thereby avoiding ambiguity while writing to or reading back from file. 
now <- Sys.time()
dt <- data.table(date = as.IDate(now),
                 time = as.ITime(now),
                 datetime = now)
dt
# The as.IDate() and as.ITime() functions from data.table extract the relevant portions from the timestamp. 
fwrite(dt, "datetime.csv", dateTimeAs = "ISO")
fread("datetime.csv") # exactly the way fwrite() wrote the columns to file.
# "squash" : writes yyyy-mm-dd hh:mm:ss as yyyymmddmmss.
fwrite(dt, "datetime1.csv", dateTimeAs = "squash")
fread("datetime1.csv") 
# hyphen and colon separator are removed. Thus columns are read back as integers. This is particularly useful for columns whose primary purpose is to allow for extraction of year, month, date, hour, minute, seconds etc. E.g, using integer division, you can easily extract the year efficiently.
20181217 %/% 10000
# "epoch": counts the number of days or seconds since the relevant epoch, which is the first of January 1970for date, time, respectively. Date, time, datetime which are less than the respective epochs would have negative values.
fwrite(dt, "datetime2.csv", dateTimeAs = "epoch")
fread("datetime2.csv") # integers denoting number of days and seconds from the respective epoch.
# The options "iso", "squash" or "epoch" are extremely fast due to specialized C code and are extensively simply tested for correctness and allow for unambiguous and fast reading of those columns. Compare fwrite() with write.table() of the Base R.
system.time(write.table(batrips, "base-r.txt"))
system.time(fwrite(batrips, "data-table.txt"))