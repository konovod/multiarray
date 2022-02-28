require "spec"
require "../src/multiarray"

enum Seasons
  Spring
  Summer
  Autumn
  Winter
end

MultiArrayUtils.declare_range_enum(Years, 2020, 2022)
