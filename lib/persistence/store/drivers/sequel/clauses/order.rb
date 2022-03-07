module Persistence
  module Store
    module Drivers
      module Sequel
        module Clauses
          class Order
            NULLS = { first: 'FIRST', last: 'LAST' }.freeze
            ORDERINGS = { asc: 'ASC', desc: 'DESC' }.freeze

            attr_reader :operation

            def initialize(operation)
              validate_orderer!(operation)
              @operation = operation
            end

            def build
              statement = ""

              return statement if operation.orderings.empty?

              first, *rest = operation.orderings
              statement << "ORDER BY #{format_ordering(first)}"
              rest.each_with_object(statement) do |ordering, acc|
                acc << ", #{format_ordering(ordering)}"
              end
            end

            private

            def format_ordering(ordering)
              field = ordering[:criteria]
              ordered = format_order(field, ordering[:order])
              format_nulls(ordered, ordering[:nulls])
            end

            def format_order(field, order)
              order = ORDERINGS[order.to_sym] || order

              "#{field} #{order}"
            end

            def format_nulls(field, nulls)
              nulls = nulls ? (NULLS[nulls.to_sym] || nulls) : NULLS[:last]

              "#{field} NULLS #{nulls}"
            end

            def validate_orderer!(operation)
              klass = Persistence::Store::Operations::Capabilities::Orderer
              return if operation.class.ancestors.include?(klass)

              msg = "The Operation isn't a Orderer"
              raise(Persistence::Errors::DriverError, msg)
            end
          end
        end
      end
    end
  end
end
