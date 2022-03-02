# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      module Capabilities
        # Makes the Operation capable of aggregating result fields.
        module Aggregator
          def aggregate(function, fields)
            case fields
            when Symbol
              field = fields
              build_field_aggregation(function, field)
            when Array
              build_fields_aggregations(function, fields)
            else
              invalid_fields!
            end
            self
          end

          private

          def build_fields_aggregations(function, fields)
            reference = fields[0]

            case reference
            when Symbol
              build_field_aggregation(function, fields[0], fields[1])
            when Array
              fields.map do |field|
                build_field_aggregation(function, field[0], field[1])
              end
            else
              invalid_fields!
            end
          end

          def build_field_aggregation(function, field, aka = nil)
            invalid_fields! unless function && field

            aggregations[field] = { function: function, alias: aka }
          end

          def invalid_fields!
            msg = "Invalid fields provided to #aggregate. Should be a Symbol, [Symbol] or [[Symbol]]"
            raise(Persistence::Errors::OperationError, msg)
          end

          def aggregations
            @aggregations ||= {}
          end
        end
      end
    end
  end
end
