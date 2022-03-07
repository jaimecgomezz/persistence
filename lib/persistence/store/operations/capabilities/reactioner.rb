# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      module Capabilities
        # Makes the operation capable of reacting to events during execution.
        module Reactioner
          # Creates the @reaction instance variable, which describes how the
          # Operation should react when facing an event. This hash should later
          # be understood by the Driver in order to build the reacting
          # component of the Directive.
          #
          # Further details on how to use this mechanism should be provided by
          # the Driver.
          #
          # Insert.set(id: 1).react(
          #   conflicting: :unique_id_constraint,
          #   action: :update,
          #   using: {
          #     id: 1
          #   }
          # )
          # => #<Insert
          #       @reaction={
          #         confliction: :unique_id_constraint,
          #         action: :update,
          #         using: {
          #           id: 2
          #         }
          #       }
          #     >
          def react(conflicting:, action:, using: {})
            clean_reactioner_configuration

            handle_conflicting!(conflicting)
            handle_action!(action)
            reaction[:using] = using

            self
          end

          def reaction
            @reaction ||= { conflicting: nil, action: nil, using: {} }
          end

          private

          def handle_conflicting!(conflicting)
            case conflicting
            when Symbol, String, Array
              reaction[:conflicting] = conflicting
            else
              msg = "Invalid :conflicting provided to #react"
              raise(Persistence::Errors::OperationError, msg)
            end
          end

          def handle_action!(action)
            case action
            when Symbol, String
              reaction[:action] = action
            else
              msg = "Invalid :action provided to #react"
              raise(Persistence::Errors::OperationError, msg)
            end
          end

          def clean_reactioner_configuration
            @reaction = { conflicting: nil, action: nil, using: {} }
          end
        end
      end
    end
  end
end
