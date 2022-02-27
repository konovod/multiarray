# multiarray

MultiArray is a shard with multidimensional arrays that can be indexed using enums or integer ranges.
It also include number of helper functions that could be useful in DSLs for multidimensional optimization and other areas.

This is WIP and just a draft for now.

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

# Years = 2020..2035 # won't work
# for now, ranges are not allowed in generics syntax, so here is a hack^
declare_range_enum(Years, 2020, 2035)

# create array with indexes being Range and Enum
# for now, variadic generics are a problem, so type name should include number of dimensions
# up to 5 dimensions would be supported.
consumption = MultiArray2(Float64, Years, Seasons).new(0.0)

# index using integers and enums
consumption[2021, Spring] = 20000

# use sum, product, max, min, mean, reduce over multiple variables
total = sum(Years, Seasons) do |y, s|
  consumption[y, s]
end

# reduce using block syntax of array creation
by_season = MultiArray1(Float64, Seasons).new do |s|
  sum(Years) do |y|
    consumption[y]
  end
end

# another way to reduce dimensions is to use `reduce` function
by_year = consumption.reduce_by(:keep, :sum)
```

TODO: Write usage instructions here

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
