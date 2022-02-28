require "./src/multiarray"

include MultiArrayUtils

enum Seasons
  Spring
  Summer
  Autumn
  Winter
end

# Years = 2020..2035
# for now, ranges are not allowed in generics syntax, so here is a hack^
declare_range_enum(Years, 2020, 2035)

# create array with indexes being Range and Enum
# for now, variadic generics are a problem, so type name should include number of dimensions
# up to 5 dimensions would be supported.
consumption = MultiArray2(Float64, Years, Seasons).new(0.0)

# index using integers and enums
consumption[2021, :spring] = 20000

# use sum, product, max, min, mean, reduce over multiple variables
total = For(Years, Seasons).sum do |y, s|
  consumption[y, s]
end

# reduce using block syntax of array creation
by_season = MultiArray1(Float64, Seasons).new do |s|
  For(Years).sum do |y|
    consumption[y, s]
  end
end

# another way to reduce dimensions is to use `reduce` function
by_year = consumption.reduce_by(:keep, :sum)
