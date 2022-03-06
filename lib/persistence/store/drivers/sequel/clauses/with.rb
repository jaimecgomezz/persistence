module Persistence
  module Store
    module Drivers
      module Sequel
        module Clauses
          # Class specialized in building SQL's WHERE clause.
          class With
            attr_reader :operation

            def initialize(operation)
              invalid_requirer! unless valid_requirer?(operation)

              @operation = operation
            end

            def build
              statement = ""

              return statement if (requirements = operation.requirements.to_a).empty?

              first, *rest = requirements

              statement << "WITH #{format_requirement(first)}"
              rest.each_with_object(statement) do |requirement, acc|
                acc << ", #{format_requirement(requirement)}"
              end
            end

            private

            def format_requirement(requirement)
              name, stmnt = requirement

              stmnt = stmnt.build if is_operation?(stmnt)

              "#{name} AS (#{stmnt})"
            end

            def is_operation?(value)
              value.class.ancestors.include?(Persistence::Store::Operations::Operation)
            end

            def valid_requirer?(operation)
              klass = Persistence::Store::Operations::Capabilities::Requirer
              operation.class.ancestors.include?(klass)
            end

            def invalid_requirer!
              msg = "The Operation provided doesn't implements the Requirer module"
              raise(Persistence::Errors::DriverError, msg)
            end
          end
        end
      end
    end
  end
end
