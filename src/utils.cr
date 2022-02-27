module MultiArrayUtils
  macro declare_range_enum(typ, start, finish)
    @[MultiArrayUtils::AllowInteger]
    enum {{typ}}
      {% for i in (start..finish) %}
        {{typ.stringify[0..0].id}}{{i}} = {{i}}
      {% end %}
    end
  end
end
