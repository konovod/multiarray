# multiarray

MultiArray is a shard with multidimensional arrays that can be indexed using enums or integer ranges.
It also include number of helper functions that could be useful in DSLs for multidimensional optimization and other areas.

This is WIP and just a sketch for now, but fuctionality in the [Usage](#Usage) section should work.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     multiarray:
       github: konovod/multiarray
   ```

2. Run `shards install`

## Usage

```crystal
require "multiarray"

include MultiArrayUtils

enum Seasons
  Spring
  Summer
  Autumn
  Winter
end

# Years = 2020..2035
# for now, ranges are not allowed in generics syntax, so here is a hacky way:
declare_range_enum(Years, 2020, 2035)
# is equivalent to
# Enum Years
# Y2020 = 2020
# Y2021 = 2021
# ...
# Y2035 = 2035
# end

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

# `#to_unsafe` returns an underlaying slice that can be passed to various bindings and libraries
# mt = LA::GMat.new(consumption.size1, consumption.size2, consumption.to_unsafe)

# you can also iterate it using `#each`, `#each_index` and `#each_with_index`:
consumption.each_with_index do |v, y, s|
  puts "[#{y}, #{s}] : #{v}"
end

# and print using `#inspect` or `#to_s`
puts consumption
```

## Development

TODO: Write development instructions here

## Contributing

1. Fork it (<https://github.com/konovod/multiarray/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Andrey Konovod](https://github.com/konovod) - creator and maintainer
