module Persistence
  module Store
    module Drivers
      module Sequel
        module Clauses
          # Class that specializes in building SQL's GROUP clause.
          class Group
            attr_reader :operation

            def initialize(operation)
              validate_grouper!(operation)
              @operation = operation
            end

            def build
              statement = ""

              return statement if operation.groupings.empty?

              first, *rest = operation.groupings
              statement << "GROUP BY #{format_grouping(first)}"
              rest.each_with_object(statement) do |grouping, acc|
                acc << ", #{format_grouping(grouping)}"
              end
            end

            private

            def format_grouping(grouping)
              grouping[:criteria]
            end

            def validate_grouper!(operation)
              klass = Persistence::Store::Operations::Capabilities::Grouper
              return if operation.class.ancestors.include?(klass)

              msg = "The Operation provided isn't a Grouper"
              raise(Persistence::Errors::DriverError, msg)
            end
          end
        end
      end
    end
  end
end
