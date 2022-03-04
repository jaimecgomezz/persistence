# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      module Capabilities
        # Makes the Operation capable of returning distinct results.
        module Differentiator
          # Defines a @distincts instance variable which is list that contains
          # descriptive hashes that should later be understood by the Driver in
          # order to build the distinctiveness component of the Directive.
          #
          # # Handles a list of criteria as positional arguments
          # Select.all.distinct(:country, :state, :municipality)
          # => #<Select:0x000055837e273178
          #       @distincts=[
          #         { criteria: :country },
          #         { criteria: :state },
          #         { criteria: :municipality },
          #       ]
          #     >
          #
          # # Handles a list of criteria as keyword arguments
          # Select.all.distinct(:country, state: { apply: :avg }, municipality: { alias: :mun })
          # => #<Select:0x000055837e273178
          #       @distincts=[
          #         { criteria: :country },
          #         { criteria: :state, apply: :avg },
          #         { criteria: :municipality, alias: :mun },
          #       ]
          #     >
          def distinct(*items, **kwitems)
            clear_previous_configuration

            items.each do |criteria|
              case criteria
              when Symbol, String
                handle_criteria(criteria)
              else
                invalid_criteria!
              end
            end

            kwitems.each do |criteria, value|
              case value
              when Hash
                hash = value
                handle_criteria_hash(criteria, hash)
              else
                invalid_criteria!
              end
            end

            self
          end

          def distincts
            @distincs ||= []
          end

          private

          def distincts_indices
            @distincs_indices ||= {}
          end

          def handle_criteria(criteria)
            if (index = distincts_indices[criteria])
              distincts.delete_at(index)
              update_distincts_indices
            end

            distincts_indices[criteria] = distincts.size
            distincts.push({ criteria: criteria })
          end

          def handle_criteria_hash(criteria, hash)
            if (index = distincts_indices[criteria])
              distincts.delete_at(index)
              update_distincts_indices
            end

            distincts_indices[criteria] = distincts.size
            distincts.push(hash.merge({ criteria: criteria }))
          end

          def update_distincts_indices
            distincts.each_with_index do |distinct, index|
              distincts_indices[distinct[:criteria]] = index
            end
          end

          def clear_previous_configuration
            @distincs = []
            @distincts_indices = {}
          end

          def invalid_criteria!
            msg = "Invalid distinctiveness criteria provided to #distinct"
            raise(Persistence::Errors::OperationError, msg)
          end
        end
      end
    end
  end
end
