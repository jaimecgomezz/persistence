# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      module Capabilities
        # Makes the operation capable of reacting to events during execution.
        module Reactioner
          # Creates the @reactions instance variable that maps events to
          # descriptive mappings that define how to react to said events. This
          # mappings should later be understood by the driver in order to build
          # query's reaction component.
          #
          # # Handle event-reaction pairs as keyword arguments
          # Insert.resource(:users).set(id: 1).react(id: :noting)
          # => #<Insert
          #       @reactions={
          #         id: {
          #           action: :nothing,
          #           constraint: :id
          #         }
          #       }
          #     >
          #
          # # Handle events with custom reaction mappings as keyword arguments
          # Insert
          #   .resource(:users)
          #   .set(id: 2, email: 'existing@mail.com')
          #   .react(email: { action: :nothing, constraint: :unique_email })
          # => #<Insert
          #       @reactions={
          #         email: {
          #           action: :nothing,
          #           constraint: :unique_email
          #         }
          #       }
          #     >
          def react(**kwitems)
            clean_reactioner_configuration

            kwitems.each do |event, reaction|
              case reaction
              when Symbol, String
                handle_reaction(event, reaction)
              when Hash
                handle_reaction_mapping(event, reaction)
              else
                invalid_reaction!(reaction)
              end
            end

            self
          end

          def reactions
            @reactions ||= {}
          end

          private

          def handle_reaction(event, reaction)
            reactions[event] = { action: reaction, constraint: event }
          end

          def handle_reaction_mapping(event, mapping)
            invalid_reaction!(mapping) unless valid_reaction_custom_mapping?(mapping)

            reactions[event] = mapping
          end

          def valid_reaction_custom_mapping?(mapping)
            required = [:action, :constraint]
            (mapping.keys & required).size == required.size
          end

          def clean_reactioner_configuration
            @reactions = {}
          end

          def invalid_reaction!(sample)
            msg = "Invalid reaction mapping provided to #react: #{sample}"
            raise(Persistence::Errors::OperationError, msg)
          end
        end
      end
    end
  end
end
