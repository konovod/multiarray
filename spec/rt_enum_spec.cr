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
end
