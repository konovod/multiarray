require "./src/multiarray"

include MultiArrayUtils

enum Seasons
  Spring
  Summer
  Autumn
  Winter
end

# Years = 2020..2035
# ranges are a runtime construct so not allowed in generics, so here is a "compile-time range" (CTRange)
alias Years = CTRange(2020, 2035)

# create array with indexes being Range and Enum
# for now, variadic generics are a problem, so type name must include number of dimensions
# up to 6 dimensions are supported.
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

# another way to reduce dimensions is to use `reduce_by` function
# this is a planned feature, I'm not sure how it should work with multiple dimensions
# by_year = consumption.reduce_by(:keep, :sum)

# `#to_unsafe` returns an underlaying `Slice(T)` that can be passed to various bindings and libraries
# mt = LA::GMat.new(consumption.size1, consumption.size2, consumption.to_unsafe)
# tensor = Tensor.new([consumption.size1, consumption.size2]) {|i| consumption.to_unsafe[i] }

# you can also iterate it using `#each`, `#each_index` and `#each_with_index`:
consumption.each_with_index do |v, y, s|
  puts "[#{y}, #{s}] : #{v}"
end

# and print using `#inspect` or `#to_s`
puts consumption
