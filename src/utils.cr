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
    def self.sum(&)
      {% begin %}  
      v = 0
      {% for typ, i in T %}
        {{typ}}.values.each do | %var{i} |
      {% end %}
        v += yield( {% for typ, i in T %} %var{i}, {% end %} )
      {% for typ, i in T %}
        end
      {% end %}
      v
      {% end %}
    end
  end
end
