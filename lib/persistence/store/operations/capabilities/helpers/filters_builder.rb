# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      module Capabilities
        module Helpers
          # Transforms user-defined plain filters into descriptive filters that
          # can be lather understood by Drivers.
          #
          # Example
          #
          # builder = FiltersBuilder.new
          #
          # builder.build({ id: 1 })
          # => { __negate: false, __operand: :eq, __value: 1 }
          #
          # builder.build({ id: [1,2,3] })
          # => { __negate: false, __operand: :in, __value: [1,2,3] }
          #
          # builder.build({ name: /[a-z]+/ })
          # => { __negate: false, __operand: :like, __value: /[a-z]+/ }
          #
          # builder.build({ __negate: false, __operand: :lt, __value: 10 })
          # { __negate: false, __operand: :lt, __value: 10 }
          #
          # builder.build({ meta: { org: { id: 1 } } })
          # {
          #   __negate: false,
          #   __operand: :nested,
          #   __value: {
          #     meta: {
          #       __negate: false,
          #       __operand: :nested,
          #       __value: {
          #         org: {
          #           __negate: false,
          #           __operand: :nested,
          #           __value: {
          #             id: {
          #               __operand: :eq,
          #               __value: 1
          #             }
          #           }
          #         }
          #       }
          #     }
          #   }
          # }
          class FiltersBuilder
            OPERANDS = {
              in: 'Value contained in values list',
              between: 'Value in range between value A and B',
              like: 'Value matching pattern',
              nested: 'Hash value',
              eq: 'Value should be equal',
              lt: 'Value should be smaller than',
              lte: 'Value must be smaller or equal than',
              gt: 'Value must be greater than',
              gte: 'Value must be greater or equal than',
              build: 'Value must be an Operation that can be #build'
            }.freeze

            def build(filters)
              if filters.is_a?(Hash)
                return filters if is_custom_filter?(filters)

                build_filters_from_hash(filters)
              else
                msg = "Filters argument must be hash, given: #{filters}"
                raise(Persistence::Errors::OperationError, msg)
              end
            end

            private

            def build_filters_from_hash(hash)
              hash.each_with_object({}) do |pair, acc|
                key, value = pair

                acc[key] = build_filter_from_value(value)
              end
            end

            def build_filter_from_value(value)
              case value
              when Array
                { __negate: false, __operand: :in, __value: value }
              when Range
                { __negate: false, __operand: :between, __value: [value.first, value.last] }
              when Regexp
                { __negate: false, __operand: :like, __value: value }
              when Hash
                return value if is_custom_filter?(value)

                { __negate: false, __operand: :nested, __value: build_filters_from_hash(value) }
              when Persistence::Store::Operations::Operation
                { __negate: false, __operand: :build, __value: value }
              else
                { __negate: false, __operand: :eq, __value: value }
              end
            end

            def is_custom_filter?(filter)
              operand = filter[:__operand]

              return false unless operand

              return true if valid_operands.include?(operand)

              msg = "Invalid operand provided to filter: #{filter}. Valid operands are: #{OPERANDS}"
              raise(Persistence::Errors::OperationError, msg)
            end

            def valid_operands
              @valid_operands ||= OPERANDS.keys
            end
          end
        end
      end
    end
  end
end
