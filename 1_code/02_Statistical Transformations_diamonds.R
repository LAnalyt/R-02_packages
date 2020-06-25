# 2. STATISTICAL TRANSFORMATIONS

# 2.1 Prerequisites ####

# Install tidyverse package if needed
if (!require("tidyverse")) install.packages("itdyverse")
# Load ggplot2 that goes with tidyverse package
library(tidyverse) 

# 2.2 The diamonds Data Frame ####

# The diamonds dataset comes in ggplot2 and contains information about ~54,000 diamonds
diamonds # including price, carat, color, clarity and cut of each diamond.
# To learn more about diamonds
?diamonds
# See the structure of the dataset
str(diamonds)

# 2.3 Create a bar chart ####

# Bar charts seem simple, but they they reveal something subtle about plots. Draw a bar chart in ggplot2 with geom_bar()
ggplot(diamonds, aes(x = cut)) + # only needs x aesthetics.
        geom_bar() # The chart shows that more diamonds are available with high-quality cuts than with low quality cuts.
# Many graphs, like scatterplots, plot the raw values of your dataset. Other graphs, like bar charts, calculate new values to plot:
# Bar charts, histograms, and frequency polygons bin your data and then plot bin counts, the number of points that fall in each bin.
# Smoothers fit a model to your data and then plot predictions from the model.
# Boxplots compute a robust summary of the distribution and display a specially formatted box.

# The algorithm used to calculate new values for a graph is called stat, short for statistical information. Learn which stat a geom uses by inspecting the default value for the stat argument
?geom_bar # default value for stat is "count", which means geom_bar() uses stat_count()
# Geoms and stats can be used interchangably
ggplot(diamonds, aes(x = cut)) + 
  stat_count() # result the same chart.

# There are 3 reasons you might need to use a stat explicitly
# You might want to override a stat
demo <- tribble(    
  ~a, ~b,
  "bar_1", 20,
  "bar_2", 30,
  "bar_3", 40
) # tripple() creates an easier to read row-by-row layout.
ggplot(demo, aes(x = a, y = b)) +
  geom_bar(stat = "identity")
# You might want to override the default mapping from transformed variables to aesthetics
ggplot(diamonds, aes(x = cut, y = ..prop.., group = 1)) +
  geom_bar()
# You might want to draw greater attention to the statistical transformation to your code
ggplot(diamonds, aes(x = cut, y = depth)) +
  stat_summary(fun.ymin = min, 
               fun.ymax = max, 
               fun.y = median)

# ggplot2 provides over 20 stats. Each stat is a function, so you can get help the usual way, e.g
?stat_bin