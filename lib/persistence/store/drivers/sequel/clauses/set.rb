# frozen_string_literal: true

module Persistence
  module Store
    module Drivers
      module Sequel
        module Clauses
          # Class specialized in building SQL's SET clause.
          class Set
            EXPRESSIONS = { default: 'DEFAULT' }

            attr_reader :operation, :params

            def initialize(operation, params)
              @operation = operation
              @params = params
            end

            def build
              return ["", params] if (assignments = operation.assignments).empty?

              first, *rest = assignments
              assignments_formatted = rest.each_with_object([format_assignment(first)]) do |assignment, acc|
                acc << format_assignment(assignment)
              end.join(", ")

              [["SET", assignments_formatted].join(" "), params]
            rescue NoMethodError
              msg = "The Operation isn't a Setter"
              raise(Persistence::Errors::DriverError, msg)
            end

            private

            def format_assignment(assignment)
              field = assignment[:__field]
              value = assignment[:__value]

              case assignment[:__kind]
              when :literal
                placeholder = "set_#{field}"

                params[placeholder.to_sym] = value
                [field, "=", [":", placeholder].join].join(" ")
              when :expression
                expression = EXPRESSIONS[value] || value
                [field, "=", expression].join(" ")
              else
                msg = "Assignment kind not supportted: #{assignment}"
                raise(Persistence::Errors::EngineError, msg)
              end
            end
          end
        end
      end
    end
  end
end
