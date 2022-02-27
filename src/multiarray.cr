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

private macro declare_macro_array(n)
class MultiArray{{n}}(T, 
  {% for i in 1..n %}
    N{{i}},
  {% end %}
  )
  @raw : Slice(T)

{% for i in 1..n %}
@[AlwaysInline]
private def size{{i}}
  \{% if N{{i}}.is_a? NumberLiteral %}
    N{{i}}
  \{% else %}
    N{{i}}.values.size
  \{% end %}
end

@[AlwaysInline]
private def start{{i}}
  \{% if N{{i}}.is_a? NumberLiteral %}
    0
  \{% else %}
    N{{i}}.values[0].to_i
  \{% end %}
end
{% end %}

def initialize(v : T)
  @raw = Slice(T).new({% for i in 1..n %} size{{i}}*{% end %}1, v)
end

def initialize(&)
  @raw = Slice(T).new({% for i in 1..n %} size{{i}}*{% end %}1) do |i|
    i1 {% for i in 2..n %} ,i{{i}} {% end %}  = i_to_index(i)
    T.new(yield(i1 {% for i in 2..n %} ,i{{i}} {% end %}))
  end
end

@[AlwaysInline]
private def raw_at(i1 {% for i in 2..n %} ,i{{i}} {% end %})
  @raw[index_to_i(i1 {% for i in 2..n %} ,i{{i}} {% end %})]
end

@[AlwaysInline]
private def raw_set(i1 {% for i in 2..n %} ,i{{i}} {% end %}, value)
  @raw[index_to_i(i1 {% for i in 2..n %} ,i{{i}} {% end %})] = value
end

{% for mask in 0...2**n %}
def []({% for i in 1..n %} n{{i}} : {{mask & (1 << (i - 1)) > 0 ? "Int32".id : "N#{i}".id}}, {% end %})
  {% for i in 1..n %}
  {% if mask & (1 << (i - 1)) > 0 %}
    \{% if !N{{i}}.is_a?(NumberLiteral) && !N{{i}}.annotation(AllowInteger) %}
    \{% raise "integer index is not allowed as #{N{{i}}}" %}
    \{% end %}
  {% end %}
  {% end %}
  raw_at({% for i in 1..n %}n{{i}}.to_i, {% end %})
end

def []=({% for i in 1..n %} n{{i}} : {{mask & (1 << (i - 1)) > 0 ? "Int32".id : "N#{i}".id}}, {% end %} value : T)
  {% for i in 1..n %}
  {% if mask & (1 << (i - 1)) > 0 %}
    \{% if !N{{i}}.is_a?(NumberLiteral) && !N{{i}}.annotation(AllowInteger) %}
    \{% raise "integer index is not allowed as #{N{{i}}}" %}
    \{% end %}
  {% end %}
  {% end %}
  raw_set({% for i in 1..n %}n{{i}}.to_i, {% end %} value)
end
{% end %}

@[AlwaysInline]
private def index_to_i({% for i in 1..n %}i{{i}}, {% end %})
  {% for i in 1..n %}
    raise IndexError.new("Index {{i}} outside of range") if i{{i}} >= size{{i}} + start{{i}} || i{{i}} < start{{i}}
  {% end %}
  v = 0  
  {% for i in 1..n %}
    v = v + (i{{i}}.to_i - start{{i}})
    {% if i < n %}
    v = v * size{{i + 1}}
    {% end %}
  {% end %}
  v
end

@[AlwaysInline]
private def i_to_index(i)
  {% for di in 0...n %}
  {% i = n - di %}
    {% if i > 1 %}
      i{{i}} = (i % size{{i}}) + start{{i}}
      i = i // size{{i}} 
    {% else %}
      i{{i}} = i + start{{i}}
    {% end %}
    \{% if !N{{i}}.is_a?(NumberLiteral) && !N{{i}}.annotation(AllowInteger) %}
    i{{i}} = N{{i}}.new(i{{i}})
    \{% end %}
  {% end %}
  {i1 {% for i in 2..n %}, i{{i}}{% end %} }
end


end

end

declare_macro_array(1)
declare_macro_array(2)
declare_macro_array(3)
declare_macro_array(4)
declare_macro_array(5)
declare_macro_array(6)
