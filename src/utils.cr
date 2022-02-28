module MultiArrayUtils
  macro declare_range_enum(typ, start, finish)
    @[MultiArrayUtils::AllowInteger]
    enum {{typ}}
      {% for i in (start..finish) %}
        {{typ.stringify[0..0].id}}{{i}} = {{i}}
      {% end %}
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
  end
end
