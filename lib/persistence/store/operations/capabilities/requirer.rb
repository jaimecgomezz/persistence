# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      module Capabilities
        # Makes the Operation being capable of requiring extra resources,
        # making them available at execution.
        module Requirer
          # Creates the @requirements instance variable which maps aliases with
          # resources, the latter being another Operation or plain strings if
          # the are difficult to express with Persistence's DSL. The Driver
          # should later understand this mappings and inject the in order to
          # build the requiring component of the Directive.
          #
          # # Handles alias-Operations pairs as keyword arguments
          # Select.requiring(
          #   independents: Select.resource(:independent)
          # ).resource(:dependent)
          # => #<Select
          #       @requirements={
          #         independents: Select.resource(:independent)
          #       }
          #     >
          #
          # # Handles alias-Directive pairs as keyword arguments
          # Select.requiring(
          #   independents: "SELECT * FROM independent"
          # ).resource(:dependent)
          # => #<Select
          #       @requirements={
          #         independents: "SELECT * FROM independent"
          #       }
          #     >
          def requiring(**kwitems)
            clear_requirer_configuration

            kwitems.each do |resource, value|
              case value
              when Persistence::Store::Operations::Operation, String
                requirements[resource] = value
              else
                invalid_required_resource!(resource)
              end
            end

            self
          end

          def requirements
            @requirements ||= {}
          end

          private

          def clear_requirer_configuration
            @requirements = {}
          end

          def invalid_required_resource!(sample)
            msg = "Invalid resource provided to #requiring: #{sample}"
            raise(Persistence::Errors::OperationError, msg)
          end
        end
      end
    end
  end
end
