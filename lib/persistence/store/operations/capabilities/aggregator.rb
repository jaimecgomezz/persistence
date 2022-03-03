# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      module Capabilities
        # Makes the Operation capable of aggregating result fields.
        module Aggregator
          # Defines a @aggregations instance variable that maps each field
          # expected to be aggregated with a descriptive hash that should be
          # later understood by the Driver in order to build query's
          # aggregation.
          #
          # # Handles single field
          # Select.where({ id: 1 }).aggregate(:income, aggregation: :sum)
          # => #<Select:0x000055837e273178
          #       @aggregations={
          #         income: { alias: nil, aggregation: :sum }
          #       }
          #     >
          #
          # # Handles a list of fields
          # Select.where({ id: 1 }).aggregate(:income, :age, aggregation: :sum)
          # => #<Select:0x000055837e273178
          #       @aggregations={
          #         income: { alias: nil, aggregation: :sum },
          #         age: { alias: nil, aggregation: :sum }
          #       }
          #     >
          #
          # # Handles fields with alias
          # Select.where({ id: 1 }).aggregate(:income, [:age, :AGE], aggregation: :sum)
          # => #<Select:0x000055837e273178
          #       @aggregations={
          #         income: { alias: nil, aggregation: :sum },
          #         age: { alias: :AGE, aggregation: :sum }
          #       }
          #     >
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
