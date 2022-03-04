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
            clear_differentiator_configuration

            items.each do |criteria|
              case criteria
              when Symbol, String
                handle_distinctiveness_criteria(criteria)
              else
                invalid_distinctiveness_criteria!(criteria)
              end
            end

            kwitems.each do |criteria, mapping|
              case mapping
              when Hash
                handle_distinctiveness_mapping(criteria, mapping)
              else
                invalid_distinctiveness_criteria!(criteria)
              end
            end

            self
          end

          def distincts
            @distincs ||= []
          end

          private

          def handle_distinctiveness_criteria(criteria)
            distincts.push({ criteria: criteria })
          end

          def handle_distinctiveness_mapping(criteria, mapping)
            distincts.push(mapping.merge({ criteria: criteria }))
          end

          def clear_differentiator_configuration
            @distincs = []
            @distincts_indices = {}
          end

          def invalid_distinctiveness_criteria!(sample)
            msg = "Invalid distinctiveness criteria provided to #distinct: #{sample}"
            raise(Persistence::Errors::OperationError, msg)
          end
        end
      end
    end
  end
end
