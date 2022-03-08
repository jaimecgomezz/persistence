module Persistence
  module Store
    module Drivers
      module Sequel
        module Clauses
          class Order
            NULLS = { first: 'FIRST', last: 'LAST' }.freeze
            ORDERINGS = { asc: 'ASC', desc: 'DESC' }.freeze

            attr_reader :operation, :params

            def initialize(operation, params)
              @operation = operation
              @params = params
            end

            def build
              return ["", params] if (orderings = operation.orderings).empty?

              first, *rest = orderings
              orderings_formatted = rest.each_with_object([format_ordering(first)]) do |ordering, acc|
                acc << format_ordering(ordering)
              end.join(", ")

              [["ORDER BY", orderings_formatted].join(" "), params]
            rescue NoMethodError
              msg = "The Operation isn't a Orderer"
              raise(Persistence::Errors::DriverError, msg)
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
          end
        end
      end
    end
  end
end
