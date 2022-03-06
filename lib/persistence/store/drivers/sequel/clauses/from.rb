module Persistence
  module Store
    module Drivers
      module Sequel
        module Clauses
          # Class specialized in building SQL's FROM clause.
          class From
            JOINS = {
              lj: 'LEFT JOIN',
              loj: 'LEFT OUTER JOIN',
              rj: 'RIGHT JOIN',
              roj: 'RIGHT OUTER JOIN',
              fj: 'FULL JOIN',
              foj: 'FULL OUTER JOIN'
            }

            attr_reader :operation

            def initialize(operation)
              invalid_operation! unless valid_operation?(operation)

              @operation = operation
            end

            def build
              statement = "FROM #{operation.source}"

              return statement if (joins = operation.joins.to_a).empty?

              first, *rest = joins
              statement << " #{format_join(first)}"
              rest.each_with_object(statement) do |join, acc|
                acc << " #{format_join(join)}"
              end
            end

            private

            def format_join(join)
              name, hash = join
              kind = hash[:kind]

              join_kind = JOINS[kind] || kind
              join_match = "#{operation.source}.#{hash[:left]} = #{name}.#{hash[:right]}"

              "#{join_kind} ON #{join_match}"
            end

            def valid_operation?(operation)
              operation.respond_to?(:source) && operation.source
            end

            def invalid_operation!
              msg = "The Operation doesn't has source"
              raise(Persistence::Errors::DriverError, msg)
            end
          end
        end
      end
    end
  end
end
