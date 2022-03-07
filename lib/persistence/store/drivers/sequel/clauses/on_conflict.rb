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
              statement = ""
              reaction = operation.reaction

              return [statement, params] unless reaction[:conflicting]

              statement << [
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
              first, *rest = fields

              statement = rest.each_with_object([first]) do |field, acc|
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

              first, *rest = using
              statement = [format_update_setter(first)]
              rest.each_with_object(statement) do |updater, acc|
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
