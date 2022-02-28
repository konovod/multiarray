require "./spec_helper"

describe MultiArrayUtils do
  it "#sum" do
    consumption = MultiArray2(Float64, Years, Seasons).new(1.0)
    consumption[2021, Seasons::Spring] = 20000
    total = MultiArrayUtils::For(Years, Seasons).sum do |y, s|
      consumption[y, s]
    end
    total.should eq 20000 + 12 - 1
  end

  it "#product" do
    consumption = MultiArray2(Float64, Years, Seasons).new(1.0)
    consumption[2021, Seasons::Spring] = 20000
    total = MultiArrayUtils::For(Years, Seasons).product do |y, s|
      consumption[y, s]
    end
    total.should eq 20000
  end

  it "#mean" do
    consumption = MultiArray2(Float64, Years, Seasons).new(1.0)
    consumption[2021, Seasons::Spring] = 25
    total = MultiArrayUtils::For(Years, Seasons).mean do |y, s|
      consumption[y, s]
    end
    total.should eq 36 / 12
  end

  it "#min" do
    consumption = MultiArray2(Float64, Years, Seasons).new(1.0)
    consumption[2021, Seasons::Spring] = 25
    MultiArrayUtils::For(Years, Seasons).min do |y, s|
      consumption[y, s]
    end.should eq 1
  end

  it "#max" do
    consumption = MultiArray2(Float64, Years, Seasons).new(1.0)
    consumption[2021, Seasons::Spring] = 25
    MultiArrayUtils::For(Years, Seasons).max do |y, s|
      consumption[y, s]
    end.should eq 25
  end

  it "#count" do
    consumption = MultiArray2(Float64, Years, Seasons).new(1.0)
    consumption[2021, Seasons::Spring] = 25
    MultiArrayUtils::For(Years, Seasons).count do |y, s|
      consumption[y, s] < 10
    end.should eq 11
    MultiArrayUtils::For(Years, Seasons).count.should eq 12
  end

  it "#reduce" do
    consumption = MultiArray2(Float64, Years, Seasons).new(1.0)
    consumption[2021, Seasons::Spring] = 25
    v = 0
    MultiArrayUtils::For(Years, Seasons).reduce(0) do |v, y, s|
      consumption[y, s] > 10 ? y : v
    end.should eq 2021
  end

  it "#map" do
    arr = MultiArrayUtils::For(Years, Seasons, Years, Seasons).map do |y1, s1, y2, s2|
      (y2*4 + s2.to_i - y1*4 + s1.to_i)
    end
    arr.should be_a MultiArray4(Int32, Years, Seasons, Years, Seasons)
    arr[2021, :autumn, 2022, :spring].should eq 6
  end
end
