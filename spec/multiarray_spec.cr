require "./spec_helper"

enum Seasons
  Spring
  Summer
  Autumn
  Winter
end

@[AllowInteger]
enum Years
  Year2020 = 2020
  Year2021 = 2021
  Year2022 = 2022
end

# a = MultiArray2(Float64, 1, Seasons).new(1)
# b = MultiArray(Float64).new({1, 2020..2035, Seasons}, 0.0)

describe Multiarray do
  # TODO: Write tests

  it "allow creating multiarray" do
    consumption = MultiArray2(Float64, Years, Seasons).new(0.0)
  end

  it "allow indexing with enums" do
    consumption = MultiArray2(Float64, Years, Seasons).new(1.0)
    consumption[Years::Year2020, Seasons::Spring].should eq 1.0
  end

  it "allow indexing with integers" do
    consumption = MultiArray2(Float64, Years, Seasons).new(2.0)
    consumption[2020, Seasons::Spring].should eq 2.0
  end

  it "raises when indexing with integers with wrong index" do
    consumption = MultiArray2(Float64, Seasons, Years).new(3.0)
    # consumption[Years::Year2020, 12] won't even compile
    expect_raises(IndexError) { consumption[Seasons::Summer, 2019] }
    expect_raises(IndexError) { consumption[Seasons::Summer, 2023] }
    consumption = MultiArray2(Float64, Years, Seasons).new(3.0)
    expect_raises(IndexError) { consumption[2019, Seasons::Summer] }
  end

  it "allow creating using block" do
    consumption = MultiArray2(Float64, Seasons, Years).new do |s1, y|
      s1.should be_a Seasons
      y.should be_a Int32
      s1.to_i*10000 + y
    end
    consumption[Seasons::Autumn, 2020].should eq 20000 + 2020
  end
end
