module Persistence
  module Store
    module Drivers
      module Sequel
        module Clauses
          # Class specialized in building SQL's INSERT clause.
          class Insert
            EXPRESSIONS = { default: 'DEFAULT' }

            attr_reader :operation

            def initialize(operation)
              @operation = operation
            end

            def build
              statement = "INSERT INTO #{operation.source}"

              return statement if operation.assignments.empty?

              first, *rest = operation.assignments
              statement << " (#{format_assignment(first)}"
              statement << rest.each_with_object("") do |assignment, acc|
                acc << ", #{format_assignment(assignment)}"
              end
              statement << ")"
            rescue NoMethodError => e
              raise_capability_error!(e.name)
            end

            private

            def format_assignment(assignment)
              assignment[:__field].to_s
            end

            def raise_capability_error!(method)
              msg = case method
                    when 'source'
                      "The Operation doesn't has a source defined"
                    when 'assignments'
                      "The Operation doesn't isn't a Setter"
                    else
                      "The Operation doesn't implements ##{method}"
                    end

              raise(Persistence::Errors::DriverError, msg)
            end
          end
        end
      end
    end
  end
end
