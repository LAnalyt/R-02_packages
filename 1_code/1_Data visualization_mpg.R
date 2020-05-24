# 1. DATA VISUALIZATION WITH GGPLOT2

# 1.1 Prerequisites ##############################################

# Install tidyverse package if needed
if (!require("tidyverse")) install.packages("itdyverse")
# Load ggplot2 that goes with tidyverse package
library(tidyverse) # only install the package once but you have to reload it every time you start a new session.
# To be explicit about where the function (or dataset) comes from, use the special form package::function()
ggplot2::ggplot() # tells explicitly that we're using ggplot() fucntion from ggplot2 package.

# 1.2 The mpg Data Frame #######################################

# mpg dataset contains observations collected by the US Environment Protection Agency on 38 models of cars
mpg     # displ: a car's engine size, in liters.
        # hwy: a car's fuel efficiency on the highway, in miles             per gallon.
        # cyl: number of cylinders
        # trans: type of transmission
        # drv: type of drive train
        # cty: city miles per gallon
        # fl: fuel type...
# To learn more about mpg
?mpg
# See the structure of the dataset
str(mpg)

# 1.3 Create a ggplot ##########################################

# Create a graph to answer the question: Do cars with big engines use more fuel than cars with small engines? 
ggplot(mpg, aes(x = displ, y = hwy)) + 
        geom_point() # negative relationship between engine size (displ) and fuel efficiency (hwy)
# Syntax: ggplot(dataset, aesthetics(x, y) + geometric layers)

# Alternative code:
ggplot(data = mpg) +
        geom_point(mapping = aes(x = displ, y = hwy))
# Try printing without aesthetic or geometric layers
ggplot(data = mpg) # blank graph

# Make a scatter plot to show the relationship between fuel efficiency (hwy) and the type of driving train (drv)
ggplot (mpg, aes(x = drv, y = hwy)) +
        geom_point() # 3 types of driving train (4wd, front-wheel, rer wheel) have different fuel efficiency.

# Make a scatter plot of class vesus drv
ggplot(mpg, aes(x = drv, y = class)) +
        geom_point() # not so useful information because both variables are categorical.

# 1.4 Aesthetic arguments ######################################

# Inspect further which type of car consumes more fuel by different color on the graph
ggplot (mpg, aes(x = displ, y = hwy, 
                 color = class)) +
        geom_point() # 2seaters which seem to fall out of the linear trend are shown to have higher fuel effiency in comparison with other type of cars that have similar engine size. They are in fact, sport cars!

# You could also choose to present different types of cars in different point sizes, but class is an unordered variable, whereas size aestheic is an ordered value.
ggplot (mpg, aes(x = displ, y = hwy, 
                 size = class)) +  # size of points in mm
        geom_point() # result a warning.

# Alpha aesthetic controls the transparency of the points
ggplot (mpg, aes(x = displ, y = hwy, alpha = class)) +
        geom_point()
# Or change the shape of the points
ggplot (mpg, aes(x = displ, y = hwy, 
                 shape = class)) +
        geom_point() #suv is not plotted because ggplot2 only use 6 shapes at a time.

# You can also set the aesthetic properties of the geometric layer manually
ggplot (mpg, aes(x = displ, y = hwy, 
                 color = "blue")) +  # has to be a string
        geom_point() # the points are not blue but reddish instead, because the color layer is specified within the aes mappings. Thus the framework tries to plot the color against an attribute “blue”, but this does not exist within the data. 
ggplot (mpg, aes(x = displ, y = hwy)) +
        geom_point(color = "blue") # the correct code would be to set the color manually in the geometric layer.

(tbc)