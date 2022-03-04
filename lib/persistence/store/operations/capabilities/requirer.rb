# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      module Capabilities
        # Makes the Operation being capable of requiring extra resources,
        # making them available at execution.
        module Requirer
          def requiring(**kwitems)
            clear_previous_configuration

            kwitems.each do |resource, value|
              case value
              when Persistence::Store::Operations::Operation, String
                requirements[resource] = value
              else
                invalid_resource!
              end
            end

            self
          end

          def requirements
            @requirements ||= {}
          end

          private

          def clear_previous_configuration
            @requirements = {}
          end

          def invalid_resource!
            msg = "Invalid resource provided to #requiring"
            raise(Persistence::Errors::OperationError, msg)
          end
        end
      end
    end
  end
end
