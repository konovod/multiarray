require "./spec_helper"

struct RTEnum1 < MultiArrayUtils::RTEnum
end

struct RTEnum2 < MultiArrayUtils::RTEnum
end

describe MultiArrayUtils::RTEnum do
  # TODO: Write tests

  it "allow setting count" do
    RTEnum1.set_size 10
    RTEnum2.set_size 15
    RTEnum1.values.size.should eq 10
    RTEnum2.values.size.should eq 15
  end

  it "allow using values" do
    RTEnum1.set_size 10
    RTEnum2.set_size 15
    expect_raises(ArgumentError) { RTEnum1.new(12) }
    RTEnum2.new(12).should eq RTEnum2.new(12)
  end

  it "allow setting names" do
    RTEnum1.set_names ["v1", "v2", "v3"]
    RTEnum2.set_names ["u1", "u2", "u3", "u4"]
    RTEnum1.values.map(&.to_s).should eq ["v1", "v2", "v3"]
    RTEnum2.values.map(&.to_s).should eq ["u1", "u2", "u3", "u4"]
    RTEnum2.set_size 5
    RTEnum1.values.map(&.to_s).should eq ["v1", "v2", "v3"]
    RTEnum2.values.map(&.to_s).should eq ["0", "1", "2", "3", "4"]
  end
end
