# frozen_string_literal: true

module Persistence
  module Store
    module Drivers
      module Sequel
        module Clauses
          # Class specialized in building SQL's WHERE clause.
          class With
            attr_reader :operation, :params

            def initialize(operation, params)
              @operation = operation
              @params = params
            end

            def build
              return ["", params] if (requirements = operation.requirements.to_a).empty?

              first, *rest = requirements
              requirements_formatted = rest.each_with_object([format_requirement(first)]) do |requirement, acc|
                acc << format_requirement(requirement)
              end.join(", ")

              [["WITH", requirements_formatted].join(" "), params]
            rescue NoMethodError
              msg = "The Operation isn't a Requirer"
              raise(Persistence::Errors::DriverError, msg)
            end

            private

            def format_requirement(requirement)
              name, stmnt = requirement

              stmnt = stmnt.build if is_operation?(stmnt)

              [name, "AS", ["(", stmnt, ")"].join].join(" ")
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
