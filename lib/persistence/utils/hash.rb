module Persistence
  module Utils
    # Conatins Hash-related functionality
    module Hash
      # Symbolize keys in a hash recursively
      #
      # @example
      #
      #   input = { 'foo' => 'bar', 'baz' => [{ 'one' => 1 }] }
      #
      #   deep_symbolize(input)
      #   # => { :foo => "bar", :baz => [{ :one => 1 }] }
      #
      # @param [Hash]
      #
      # @return [Hash]
      def self.deep_symbolize(hash)
        hash.each_with_object({}) do |(key, value), output|
          output[key.to_sym] =
            case value
            when Hash
              deep_symbolize(value)
            when Array
              value.map do |item|
                item.is_a?(::Hash) ? deep_symbolize(item) : item
              end
            else
              value
            end
        end
      end

      # Deep duplicates hash values
      #
      # The output of this function is a deep duplicate of the input.
      # Any further modification on the input, won't be reflected on the output
      # and viceversa.
      #
      # @param input [::Hash] the input
      #
      # @return [::Hash] the deep duplicate of input
      #
      # @example Basic Usage
      #   input  = { "a" => { "b" => { "c" => [1, 2, 3] } } }
      #   output = Persistence::Utils::Hash.deep_dup(input)
      #     # => {"a"=>{"b"=>{"c"=>[1,2,3]}}}
      #
      #   output.class
      #     # => Hash
      #
      #
      #
      #   # mutations on input aren't reflected on output
      #
      #   input["a"]["b"]["c"] << 4
      #   output.dig("a", "b", "c")
      #     # => [1, 2, 3]
      #
      #
      #
      #   # mutations on output aren't reflected on input
      #
      #   output["a"].delete("b")
      #   input
      #     # => {"a"=>{"b"=>{"c"=>[1,2,3,4]}}}
      def self.deep_dup(input)
        input.transform_values do |v|
          case v
          when ::Hash
            deep_dup(v)
          else
            v.dup
          end
        end
      end
    end
  end
end
