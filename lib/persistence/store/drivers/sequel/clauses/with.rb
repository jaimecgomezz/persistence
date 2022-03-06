module Persistence
  module Store
    module Drivers
      module Sequel
        module Clauses
          # Class specialized in building SQL's WHERE clause.
          class With < Clause
            def build
              statement = ""

              return statement if (requirements = operation.requirements.to_a).empty?

              first, *rest = requirements

              statement << "WITH #{format_requirement(first)}"
              rest.each_with_object(statement) do |requirement, acc|
                acc << ", #{format_requirement(requirement)}"
              end
            rescue NoMethodError
              msg = "The Operation provided doesn't implements the Requirer module"
              raise(Persistence::Errors::DriverError, msg)
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
          end
        end
      end
    end
  end
end
