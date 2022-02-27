# TODO: Write documentation for `Multiarray`
module Multiarray
  VERSION = "0.1.0"

  # TODO: Put your code here
end

annotation AllowInteger
end

# class MultiArray(T)
#   @raw : Slice(T)
#   @dimensions : Array(Int32)
#   @starts : Array(Int32)

#   # @reusable_index : Array(Int32)

#   def initialize(dimensions, value : T)
#     @dimensions = Array(Int32).new(dimensions.size) do |i|
#       dim = dimensions[i]
#       case dim
#       when Enum.class
#         dim.values.size
#       when Range
#         dim.end - dim.begin + 1
#       when Int
#         Int32.new(dim)
#       else
#         raise "unsupported dimension: #{dim}"
#       end
#     end
#     @starts = Array(Int32).new(dimensions.size) do |i|
#       dim = dimensions[i]
#       case dim
#       when Enum.class
#         dim.values.first.to_i
#       when Range
#         dim.begin
#       when Int
#         0
#       else
#         raise "unsupported dimension: #{dim}"
#       end
#     end
#     total = @dimensions.sum
#     @raw = Slice(T).new(total, value)
#   end

#   def initialize(dimensions, &)
#     @dimensions = dimensions.map do |dim|
#       case dim
#       when Enum
#         dim.values.size
#       when Range
#         dim.end - dim.start + 1
#       when Int
#         Int32.new(dim)
#       else
#         raise "unsupported dimension: #{dim}"
#       end
#     end
#     @starts = dimensions.map do |dim|
#       case dim
#       when Enum
#         dim.values.first.to_i
#       when Range
#         dim.start
#       when Int
#         0
#       else
#         raise "unsupported dimension: #{dim}"
#       end
#     end
#     total = @dimensions.sum
#     @raw = Slice(T).new(total) do |i|
#       yield(i)
#     end
#   end

#   private def index_to_i(*args)
#     result = 0
#     args.each_with_index do |v, i|
#       result = result * @dimensions[i - 1] unless i == 0
#       result += v.to_i - @starts[i]
#     end
#     result
#   end

#   private def i_to_index(*args)
#   end
# end

class MultiArray2(T, N1, N2)
  @raw : Slice(T)

  @[AlwaysInline]
  private def size1
    {% if N1.is_a? NumberLiteral %}
      N1
    {% else %}
      N1.values.size
    {% end %}
  end

  @[AlwaysInline]
  private def start1
    {% if N1.is_a? NumberLiteral %}
      0
    {% else %}
      N1.values[0].to_i
    {% end %}
  end

  @[AlwaysInline]
  private def size2
    {% if N2.is_a? NumberLiteral %}
      N2
    {% else %}
      N2.values.size
    {% end %}
  end

  @[AlwaysInline]
  private def start2
    {% if N2.is_a? NumberLiteral %}
      0
    {% else %}
      N2.values[0].to_i
    {% end %}
  end

  @[AlwaysInline]
  private def i_to_index(i)
    i1 = (i // size2) + start1
    i2 = (i % size2) + start2
    {% if !N1.is_a?(NumberLiteral) && !N1.annotation(AllowInteger) %}
      i1 = N1.new(i1)
    {% end %}
    {% if !N2.is_a?(NumberLiteral) && !N2.annotation(AllowInteger) %}
      i2 = N2.new(i2)
    {% end %}
    {i1, i2}
  end

  @[AlwaysInline]
  private def index_to_i(i1, i2)
    raise IndexError.new("Index outside of range") if i2 >= size2 + start2 || i2 < start2 || i1 < start1
    (i1.to_i - start1)*size2 + (i2.to_i - start2)
  end

  def initialize(v : T)
    @raw = Slice(T).new(size1*size2, v)
  end

  def initialize(&)
    @raw = Slice(T).new(size1*size2) do |i|
      i1, i2 = i_to_index(i)
      T.new(yield(i1, i2))
    end
  end

  @[AlwaysInline]
  private def raw_at(i1, i2)
    @raw[index_to_i(i1, i2)]
  end

  @[AlwaysInline]
  private def raw_set(i1, i2, value)
    @raw[index_to_i(i1, i2)] = value
  end

  def [](n1 : N1, n2 : N2)
    raw_at(n1.to_i, n2.to_i)
  end

  def [](n1 : Int32, n2 : N2)
    {% if !N1.is_a?(NumberLiteral) && !N1.annotation(AllowInteger) %}
      raise "integer index is not allowed as #{N1}"
    {% end %}
    raw_at(n1.to_i, n2.to_i)
  end

  def [](n1 : N1, n2 : Int32)
    {% if !N2.is_a?(NumberLiteral) && !N2.annotation(AllowInteger) %}
    {% raise "integer index is not allowed as #{N2}" %}
    {% end %}
    raw_at(n1.to_i, n2.to_i)
  end

  def [](n1 : Int32, n2 : Int32)
    {% if !N1.is_a?(NumberLiteral) && !N1.annotation(AllowInteger) %}
    {% raise "integer index is not allowed as #{N1}" %}
    {% end %}
    {% if !N2.is_a?(NumberLiteral) && !N2.annotation(AllowInteger) %}
    {% raise "integer index is not allowed as #{N2}" %}
    {% end %}
    raw_at(n1.to_i, n2.to_i)
  end

  def []=(n1 : N1, n2 : N2, value)
    raw_set(n1.to_i, n2.to_i, value)
  end

  def []=(n1 : Int32, n2 : N2, value)
    {% if !N1.is_a?(NumberLiteral) && !N1.annotation(AllowInteger) %}
      raise "integer index is not allowed as #{N1}"
    {% end %}
    raw_set(n1.to_i, n2.to_i, value)
  end

  def []=(n1 : N1, n2 : Int32, value)
    {% if !N2.is_a?(NumberLiteral) && !N2.annotation(AllowInteger) %}
    {% raise "integer index is not allowed as #{N2}" %}
    {% end %}
    raw_set(n1.to_i, n2.to_i, value)
  end

  def []=(n1 : Int32, n2 : Int32, value)
    {% if !N1.is_a?(NumberLiteral) && !N1.annotation(AllowInteger) %}
    {% raise "integer index is not allowed as #{N1}" %}
    {% end %}
    {% if !N2.is_a?(NumberLiteral) && !N2.annotation(AllowInteger) %}
    {% raise "integer index is not allowed as #{N2}" %}
    {% end %}
    raw_set(n1.to_i, n2.to_i, value)
  end
end
