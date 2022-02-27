require "./spec_helper"

enum Seasons
  Spring
  Summer
  Autumn
  Winter
end

MultiArrayUtils.declare_range_enum(Years, 2020, 2022)

describe "MultiArray" do
  # TODO: Write tests

  it "allow creating multiarray" do
    consumption = MultiArray2(Float64, Years, Seasons).new(0.0)
  end

  it "allow indexing with enums" do
    consumption = MultiArray2(Float64, Years, Seasons).new(1.0)
    consumption[Years::Y2020, Seasons::Spring].should eq 1.0
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

  it "allow creating using number as index" do
    a = MultiArray2(Float64, 6, Seasons).new(1.0)
    a[1, Seasons::Autumn] = 2.0
    a[1, Seasons::Autumn].should eq 2
  end

  it "allow creating using two numbers as index" do
    a = MultiArray2(Float64, 10, 10).new(1.0)
    a[5, 6] = 2.0
    a[6, 5].should eq 1
    a[5, 6].should eq 2
    expect_raises(IndexError) { a[1, 10] }
    expect_raises(IndexError) { a[10, 1] }
  end

  it "allow different number of dimensions" do
    a = MultiArray1(Float64, Seasons).new(1.0)
    a[Seasons::Autumn] = 2.0
    a[Seasons::Autumn].should eq 2

    b = MultiArray3(Float64, Seasons, Years, 5).new(1.0)
    b[Seasons::Autumn, 2020, 4] = 2.0
    b[Seasons::Autumn, 2021, 0].should eq 1
    b[Seasons::Autumn, 2020, 4].should eq 2

    c = MultiArray5(Float64, Seasons, Years, 5, Seasons, Years).new(1.0)
    c[Seasons::Autumn, 2022, 4, Seasons::Spring, 2021] = 2.0
    c[Seasons::Autumn, 2022, 4, Seasons::Winter, 2021].should eq 1
    c[Seasons::Autumn, 2022, 4, Seasons::Spring, 2021].should eq 2
  end
end
