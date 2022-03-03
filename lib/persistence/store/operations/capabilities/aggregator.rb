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
          # # Handles a list of fields as positional arguments
          # Select.where({ id: 1 }).aggregate(:income, :age, aggregation: :sum)
          # => #<Select:0x000055837e273178
          #       @aggregations={
          #         income: { alias: nil, aggregation: :sum },
          #         age: { alias: nil, aggregation: :sum }
          #       }
          #     >
          #
          # # Handles a list of fields with their aliases as keyword arguments
          # Select.where({ id: 1 }).aggregate(:income, age: :AGE, aggregation: :sum)
          # => #<Select:0x000055837e273178
          #       @aggregations={
          #         income: { alias: nil, aggregation: :sum },
          #         age: { alias: :AGE, aggregation: :sum }
          #       }
          #     >
          #
          # # Handles a list of fields with custom mappings as keyword arguments
          # Select.where({ id: 1 }).aggregate(
          #   :income,
          #   age: {
          #     alias: :AGE,
          #     aggregation: :max
          #   },
          #   aggregation: :sum
          # )
          # => #<Select:0x000055837e273178
          #       @aggregations={
          #         income: { alias: nil, aggregation: :sum },
          #         age: { alias: :AGE, aggregation: :max }
          #       }
          #     >
          def aggregate(*items, **kwitems)
            aggregation, remaining = kwarg_from_kwitems(kwitems, :aggregation)

            items.map do |item|
              case item
              when Symbol, String
                field = item
                handle_field(aggregation, field)
              else
                invalid_fields!
              end
            end

            remaining.each do |field, value|
              case value
              when Symbol, String
                handle_field(aggregation, field, value)
              when Hash
                aggregations[field] = value
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

          def kwarg_from_kwitems(kwitems, kwarg)
            value = kwitems[kwarg]
            remaining = kwitems.slice(*kwitems.keys - [kwarg])
            [value, remaining]
          end

          def handle_field(aggregation, field, aka = nil)
            missing_aggregation! unless aggregation
            aggregations[field] = { alias: aka, aggregation: aggregation }
          end

          def invalid_fields!
            msg = "Invalid fields provided to #aggregate"
            raise(Persistence::Errors::OperationError, msg)
          end

          def missing_aggregation!
            msg = "The kwarg :aggregation wasn't provided to #aggregate"
            raise(Persistence::Errors::OperationError, msg)
          end
        end
      end
    end
  end
end
