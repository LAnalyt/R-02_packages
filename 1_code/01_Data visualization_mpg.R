# 1. DATA VISUALIZATION WITH GGPLOT2

# 1.1 Prerequisites ####

# Install tidyverse package if needed
if (!require("tidyverse")) install.packages("itdyverse")
# Load ggplot2 that goes with tidyverse package
library(tidyverse) # only install the package once but you have to reload it every time you start a new session.
# To be explicit about where the function (or dataset) comes from, use the special form package::function()
ggplot2::ggplot() # tells explicitly that we're using ggplot() fucntion from ggplot2 package.

# 1.2 The mpg Data Frame ####

# mpg data set contains observations collected by the US Environment Protection Agency on 38 models of cars
mpg     # displ: a car's engine size, in liters.
        # hwy: a car's fuel efficiency on the highway (miles per gallon)
        # cyl: number of cylinders
        # trans: type of transmission
        # drv: type of drive train
        # cty: city miles per gallon
        # fl: fuel type...
# To learn more about mpg
?mpg
# See the structure of the dataset
str(mpg)

# 1.3 Create a ggplot ####

# Create a graph to answer the question: Do cars with big engines use more fuel than cars with small engines? 
ggplot(mpg, aes(displ, y = hwy)) + 
        geom_point() # negative relationship between engine size (displ) and fuel efficiency (hwy)
# Syntax: ggplot(dataset, aesthetics(x, y) + geometric layers)

# Alternative code:
ggplot(data = mpg) +
        geom_point(mapping = aes(x = displ, y = hwy))
# Try printing without aesthetic or geometric layers
ggplot(data = mpg) # blank graph

# Make a scatter plot to show the relationship between fuel efficiency (hwy) and the type of driving train (drv)
ggplot (mpg, aes(drv, hwy)) +
        geom_point() # 3 types of driving train (4wd, front-wheel, rear wheel) have different fuel efficiency.

# Make a scatter plot of class vesus drv
ggplot(mpg, aes(drv, class)) +
        geom_point() # not so useful information because both variables are categorical.

# 1.4 Aesthetic arguments ####

# Inspect further which type of car consumes more fuel by different color on the graph
ggplot (mpg, aes(displ, hwy, 
                 color = class)) +
        geom_point() # 2seaters which seem to fall out of the linear trend are shown to have higher fuel effiency in comparison with other type of cars that have similar engine size. They are in fact, sport cars!
# ggplot2 automatically assign a unique level of the aesthetic (here unique color) to each unique value of the variable, a process known as scaling.

# Different types of cars can be presented in different point sizes, but class is an unordered variable, whereas size aestheic is an ordered value.
ggplot (mpg, aes(displ, hwy, 
                 size = class)) +  # size of points in mm
        geom_point() # result a warning.
# Alpha aesthetic controls the transparency of the points
ggplot (mpg, aes(displ, hwy, 
                 alpha = class)) +
        geom_point()
# Or change the shape of the points
ggplot (mpg, aes(displ, hwy, 
                 shape = class)) +
        geom_point() #suv is not plotted because ggplot2 only use 6 shapes at a time.

# Aesthetic properties of the geometric layer can be changed manually
ggplot (mpg, aes(displ, hwy, 
                 color = "blue")) +  # has to be a string
        geom_point() # the points are not blue but reddish instead, because the color layer is specified within the aes mappings. Thus the framework tries to plot the color against an attribute “blue”, but this does not exist within the data. 
ggplot (mpg, aes(displ, hwy)) +
        geom_point(color = "blue") # the correct code would be to set the color manually in the geometric layer.
# By default the points are in mm. Change thickness of the points
ggplot (mpg, aes(displ, hwy, 
                 stroke = 2)) +
        geom_point(color = "blue")

# Map a continuous variable to color, size, and shape
ggplot (mpg, aes(displ, hwy, 
                 color = cyl, 
                 size = hwy, 
                 shape = drv)) +
        geom_point()
# Or map the same variable to multiple aesthetics
ggplot (mpg, aes(displ, hwy, 
                 color = cyl, 
                 size = cyl)) +
        geom_point()
# Aesthetics could be assigned to other values, not just variables
ggplot (mpg, aes(displ, hwy, 
                 color = displ < 5)) +
        geom_point()

#1.5 Facets

# One way to add additional variables is with aesthetics. Another way, particularly useful for categorical variables, is to split the plot into facets, subplots that each display one subset of the data.
ggplot (mpg, aes(displ, hwy)) +
        geom_point() +
        facet_wrap(~class) # ~ followed by a variable name
# Set the number of rows or columns 
ggplot (mpg, aes(displ, hwy)) +
        geom_point() +
        facet_wrap(~ class, nrow = 2)
# To facet the plot on the combination of the 2 variables, add facet_grid() with the formular using tilde ~ symbol
ggplot (mpg, aes(displ, hwy)) +
        geom_point() +
        facet_grid(drv ~ class)
# Facet not in the rows or columns dimension
ggplot (mpg, aes(displ, hwy)) +
        geom_point() +
        facet_grid(. ~ cyl) # use the dot . instead
ggplot (mpg, aes(displ, hwy)) +
        geom_point() +
        facet_grid(drv ~ .)
# Facet on a continuous variable will result facets for each value
ggplot (mpg, aes(cyl, hwy)) +
        geom_point() +
        facet_wrap(~displ)
# With faceting it is easier to examine the individual cases. With coloring it is easier to see how the classes are clustered overall. With larger datasets it's more likely to see the overall clustering than the individual point clouds.

# 1.5 Geometric objects ####

# A geom is the geometrical object that a plot uses to represent data. To change the geom in the plot, change the geom() function
ggplot(mpg, aes(displ, hwy)) +
        geom_point()  # scatter plot like previous examples
ggplot(mpg, aes(displ, hwy)) +
        geom_smooth() # smoothed conditional means aids the eye in seeing patterns in the presence of overplotting.
# Not every aesthetics works with every geom. E.g, you could set the shape of a point, but not a line. geom_smooth() sets different linetypes for each unique value of the variable
ggplot(mpg, aes(displ, hwy, linetype = drv)) + 
        geom_smooth()

# Ggplot2 provides over 30 geoms. Many geoms, like geom_smooth(), use a single geometric object to display multiple rows of data. Ggplot2 will automatically group the data for these geoms whenever you map an aesthetic to a discrete variable.
ggplot(mpg, aes(displ, hwy, group = drv)) +
        geom_smooth()
ggplot(mpg, aes(displ, hwy, color = drv)) +
        geom_smooth(show.legend = FALSE) # hide legend

# To display multiple geoms in the same plot, add multiple geom() functions
ggplot(mpg, aes(displ, hwy)) +
        geom_point() +
        geom_smooth()
# If you put mapping in a geom() function, ggplot2 will treat them as local mappings for the layer. It will use these mappings to extend or overwrite the global mappings for that layer only.
ggplot(mpg, aes(displ, hwy)) +
        geom_point(aes(color = class)) +
        geom_smooth()
# Specify different data for each layer
ggplot(mpg, aes(displ, hwy)) + 
        geom_point(aes(color = class)) +
        geom_smooth(data = filter(mpg, class == "subcompact"), 
                    se = FALSE) # hide the confidence interval