# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      module Capabilities
        # Makes the Operation capable of aggregating result fields.
        module Aggregator
          def aggregate(*items, aggregation:)
            items.map do |item|
              case item
              when Symbol, String
                field = item
                handle_field(aggregation, field)
              when Array
                field, aka = item
                handle_field(aggregation, field, aka)
              else
                invalid_fields!
              end
            end
            self
          end

          def aggregations
            @aggregations ||= {}
          end

          private

          def handle_field(aggregation, field, aka = nil)
            aggregations[field] = { alias: aka, aggregation: aggregation }
          end

          def invalid_fields!
            msg = "Invalid fields provided to #aggregate"
            raise(Persistence::Errors::OperationError, msg)
          end
        end
      end
    end
  end
end
