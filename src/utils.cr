module MultiArrayUtils
  # Compile-time range.
  # Mimics `Enum` as a MultiArray index: has `#values` to iterate and `#new`, but `#new` returns Int32 instead of Enums
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

  # "enum" with list of values filled at runtime.
  # Mimics `Enum` as a MultiArray index: has `#values` to iterate and `#new`
  # Can be filled with list of strings or count of values:
  # ```
  # struct Stations < RTEnum
  # end
  #
  # Stations.set_names("Station1", "Station2", "Station3")
  # # alternatively,
  # # Stations.set_count(15)
  #
  # v1 = Stations.new(0)
  # v2 = Stations.new("Station1")
  # v1.should eq v2
  # ```
  abstract struct RTEnum
    @raw : Int32

    def to_i
      @raw
    end

    def initialize(@raw, *, dont_check = false)
      raise ArgumentError.new("value #{@raw} is outside range #{0}..#{@@values.size - 1}") unless dont_check || (0...@@values.size).includes?(@raw)
    end

    def initialize(other : self)
      @raw = other.to_i
    end

    def initialize(value : String)
      @raw = @@names_to_id[value]
    end

    @@values_was_set = false
    @@values = [] of RTEnum
    @@names : Array(String)?
    @@names_to_id = {} of String => Int32

    def self.values
      @@values.as(Array(self))
    end

    private def self.build_str_map
      @@names_to_id.clear
      if names = @@names
        names.each_with_index do |s, i|
          @@names_to_id[s] = i
        end
      end
    end

    def self.set_size(count, dont_lock = false)
      raise "Changing values at runtime will break existing MultiArray, use 'dont_lock: true' if you are sure" if (!dont_lock) && @@values_was_set
      @@values_was_set = true
      @@names = nil
      @@values = Array(self).new(count) { |i| self.new(i, dont_check: true) }
      build_str_map
    end

    def self.set_names(names, *, dont_lock = false)
      raise "Changing values at runtime will break existing MultiArray, use 'dont_lock: true' if you are sure" if (!dont_lock) && @@values_was_set
      @@values_was_set = true
      n = names.size
      @@names = Array(String).new(n) { |i| names[i] }
      @@values = Array(self).new(n) { |i| self.new(i, dont_check: true) }
      build_str_map
    end

    def to_s(io)
      if names = @@names
        io << names[@raw]
      else
        io << @raw
      end
    end

    def inspect(io)
      io << self.class.name << "{"
      to_s(io)
      io << "}"
    end
  end

  module For(*T)
    private macro define_reduce(name, operation)
      def self.{{name}}(&)
        \{% begin %}  
        found = false
        v = uninitialized typeof( yield( \{% for typ, i in T %} \{{typ}}.values[0], \{% end %} ))
        \{% for typ, i in T %}
          \{{typ}}.values.each do | \%var{i} |
        \{% end %}
          if found 
            value = yield( \{% for typ, i in T %} \%var{i}, \{% end %} )
            {{operation.id}}
          else
            found = true
            v = yield( \{% for typ, i in T %} \%var{i}, \{% end %} )
          end
        \{% for typ, i in T %}
          end
        \{% end %}
        v
        \{% end %}
      end
    end

    define_reduce(sum, "v+=value")
    define_reduce(product, "v*=value")
    define_reduce(max, "v = value if v < value")
    define_reduce(min, "v = value if v > value")

    def self.mean(&)
      {% begin %}
      (sum { |*args| yield(*args) } ) {% for typ in T %} / {{typ}}.values.size {% end %}
      {% end %}
    end

    def self.reduce(initial, &)
      {% begin %}  
      v = initial
      {% for typ, i in T %}
        {{typ}}.values.each do | %var{i} |
      {% end %}
          v = yield( v, {% for typ, i in T %} %var{i}, {% end %} )
      {% for typ, i in T %}
        end
      {% end %}
      v
      {% end %}
    end

    def self.count(&)
      reduce(0) { |v, *args| yield(*args) ? v + 1 : v }
    end

    def self.count
      {% begin %}  
      1 {% for typ in T %} * {{typ}}.values.size {% end %}
      {% end %}
    end

    def self.map(&)
      {% begin %}
        MultiArray{{T.size}}(typeof(yield({% for typ, i in T %} {{typ}}.values[0], {% end %})), *T).new { |*args| yield(*args)}
      {% end %}
    end
  end
end
