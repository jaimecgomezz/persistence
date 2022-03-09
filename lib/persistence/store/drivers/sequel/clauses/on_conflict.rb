# frozen_string_literal: true

module Persistence
  module Store
    module Drivers
      module Sequel
        module Clauses
          # Class specialized in building the ON CONFLICT clause.
          class OnConflict
            attr_reader :operation, :params

            def initialize(operation, params)
              @operation = operation
              @params = params
            end

            def build
              reaction = operation.reaction

              return ["", params] unless reaction[:conflicting]

              statement = [
                "ON CONFLICT",
                format_conflicting_constraints(reaction[:conflicting]),
                format_conflicting_action(reaction[:action], reaction[:using])
              ].join(" ")

              [statement, params]
            rescue NoMethodError
              msg = "The Operation isn't a Setter"
              raise(Persistence::Errors::DriverError, msg)
            end

            private

            def format_conflicting_constraints(conflicting)
              case conflicting
              when Symbol, String
                "ON CONSTRAINT #{conflicting}"
              when Array
                format_conflicting_fields(conflicting)
              end
            end

            def format_conflicting_fields(fields)
              statement = fields.each_with_object([]) do |field, acc|
                acc << field
              end.join(", ")

              ["(", statement, ")"].join
            end

            def format_conflicting_action(action, using)
              case action.to_sym
              when :nothing
                "DO NOTHING"
              when :update
                ["DO UPDATE SET", format_update_action(using)].join(" ")
              end
            end

            def format_update_action(using)
              return "" if (using = using.to_a).empty?

              using.each_with_object([]) do |updater, acc|
                acc << format_update_setter(updater)
              end.join(", ")
            end

            def format_update_setter(updater)
              field, hash = updater

              case hash[:kind].to_sym
              when :literal
                placeholder = "conflicting_#{field}"
                params[placeholder.to_sym] = hash[:value]

                "#{field} = :#{placeholder}"
              when :expression
                "#{field} = #{hash[:value]}"
              end
            end
          end
        end
      end
    end
  end
end
