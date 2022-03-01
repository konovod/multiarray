require "./utils"

module MultiArrayUtils
  # Compile-time range.
  # Mimics `Enum` as an array index: has `#values` to iterate and `#new`, but `#new` returns Int32 instead of Enums
  module CTRange(N1, N2)
    private module CTRangeValues(N1, N2)
      def self.[](index)
        index + N1
      end

      def self.size
        N2 - N1 + 1
      end

      def self.first
        N1
      end

      def self.each(&)
        (N1..N2).each do |i|
          yield(i)
        end
      end
    end

    def self.values
      CTRangeValues(N1, N2)
    end

    def self.new(value)
      raise ArgumentError.new("value #{value} is outside range #{N1}..#{N2}") unless (N1..N2).includes?(value)
      value
    end
  end
end

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
    \{% if !N{{i}}.is_a?(NumberLiteral) && N{{i}} < Enum %}
    \{% raise "integer index is not allowed as #{N{{i}}}" %}
    \{% end %}
  {% end %}
  {% end %}
  raw_at({% for i in 1..n %}n{{i}}.to_i, {% end %})
end

def []=({% for i in 1..n %} n{{i}} : {{mask & (1 << (i - 1)) > 0 ? "Int32".id : "N#{i}".id}}, {% end %} value : T)
  {% for i in 1..n %}
  {% if mask & (1 << (i - 1)) > 0 %}
    \{% if !N{{i}}.is_a?(NumberLiteral) && N{{i}} < Enum %}
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
    \{% if !N{{i}}.is_a?(NumberLiteral) && N{{i}} < Enum %}
      i{{i}} = N{{i}}.new(i{{i}})
    \{% end %}
  {% end %}
  return i1 {% for i in 2..n %}, i{{i}}{% end %}
end

def inspect(io)
  to_s(io)
end

def to_s(io)
  io << self.class << ":\n"
  {% begin %}
  {% for i in 1...n %}
    (start{{i}} ... (start{{i}}+size{{i}})).each do |i{{i}}| 
  {% end %}
    {% for i in 1...n %}
      \{% if !N{{i}}.is_a?(NumberLiteral) && N{{i}} < Enum %}
        i{{i}} = N{{i}}.new(i{{i}})
      \{% end %}
    {% end %}
    {% if n > 1 %}
      io << "  [" << i1 {% for i in 2...n %} << ", " << i{{i}} {% end %} << "]: "
    {% end %}
      (start{{n}} ... (start{{n}}+size{{n}})).each do |i{{n}}|
        last = (i{{n}} == start{{n}}+size{{n}}-1)
        \{% if !N{{n}}.is_a?(NumberLiteral) && N{{n}} < Enum %}
          i{{n}} = N{{n}}.new(i{{n}})
        \{% end %}
        io << self[{% for i in 1..n %} i{{i}},  {% end %}] << (last ? "\n" : ", ")
      end
  {% for i in 1...n %}
    end
  {% end %}
  {% end %}
end

def to_unsafe
  @raw
end

def each(&)
  @raw.each { |v| yield(v) }
end

def each_with_index
  @raw.each_with_index { |v, i| yield(v, *i_to_index(i)) }
end

def each_index
  @raw.each_index { |i| yield(*i_to_index(i)) }
end



end

end

declare_macro_array(1)
declare_macro_array(2)
declare_macro_array(3)
declare_macro_array(4)
declare_macro_array(5)
declare_macro_array(6)
