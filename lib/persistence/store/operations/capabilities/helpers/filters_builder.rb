# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      module Capabilities
        module Helpers
          class FiltersBuilder
            attr_reader :filters

            def initialize(filters)
              @filters = filters
            end

            def build
              build_hash_config(filters)
            end

            private

            def build_hash_config(hash)
              hash.each_with_object({}) do |pair, acc|
                key, value = pair
                acc[key] = filter_config_from(value)
              end
            end

            def filter_config_from(value)
              case value
              when Array
                { operand: :in, value: value }
              when Range
                { operand: :between, value: [value.first, value.last] }
              when Regexp
                { operand: :like, value: value }
              when Hash
                return value if (value.keys & %i[operand value]).size == 2

                { operand: :nested, value: build_hash_config(value) }
              else
                { operand: :eq, value: value }
              end
            end
          end
        end
      end
    end
  end
end
