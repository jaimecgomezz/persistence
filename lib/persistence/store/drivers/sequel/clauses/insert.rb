# frozen_string_literal: true

module Persistence
  module Store
    module Drivers
      module Sequel
        module Clauses
          # Class specialized in building SQL's INSERT clause.
          class Insert
            EXPRESSIONS = { default: 'DEFAULT' }

            attr_reader :operation, :params

            def initialize(operation, params)
              @operation = operation
              @params = params
            end

            def build
              base = "INSERT INTO #{operation.source}"

              return [base, params] if (assignments = operation.assignments).empty?

              fields_formatted = assignments.each_with_object([]) do |assignment, acc|
                acc << assignment[:__field]
              end.join(", ")

              [[base, ["(", fields_formatted, ")"].join].join(" "), params]
            rescue NoMethodError => e
              raise_capability_error!(e.name)
            end

            private

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
