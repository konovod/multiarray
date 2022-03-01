require "spec"
require "../src/multiarray"

enum Seasons
  Spring
  Summer
  Autumn
  Winter
end

alias Years = MultiArrayUtils::CTRange(2020, 2022)
