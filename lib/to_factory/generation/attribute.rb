module ToFactory
  module Generation
    class Attribute
      def initialize(attribute, value)
        @attribute = attribute
        @value = value
      end

      def to_s
        setter = "#{@attribute}#{inspect_value(@value)}"

        if ToFactory.new_syntax?
          "    #{setter}"
        else
          "  o.#{setter}"
        end
      end

      def inspect_value(value, nested=false)
        formatted = case value
        when Time, DateTime
          inspect_time(value)
        when BigDecimal
          value.to_f.inspect
        when Hash
          inspect_hash(value, nested)
        when Array
          value.map{|v| inspect_value(v)}
        else
          value.inspect
        end

        if !value.is_a?(Hash) && !nested
          formatted = " #{formatted}"
        end

        formatted
      end

      private

      def inspect_time(value)
        time = in_utc(value).strftime("%Y-%m-%dT%H:%M%Z").inspect
        time.gsub(/UTC"$/, "Z\"").gsub(/GMT"$/, "Z\"")
      end

      def inspect_hash(value, nested)
        formatted = value.keys.inject([]) do |a, key|
          formatted_key = inspect_value(key, true)
          formatted_value = inspect_value(value.fetch(key), true)
          a << "#{formatted_key} => #{formatted_value}"
        end.join(', ')

        if nested
          "{#{formatted}}"
        else
          "({#{formatted}})"
        end
      end
      def in_utc(time)
        time.utc
      end
    end
  end
end

