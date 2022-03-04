# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      module Capabilities
        # Makes the Operation capable of grouping results.
        module Grouper
          # Creates the @groupings instance variable that contains a list of
          # descriptive hashes that the Driver should later understand in order
          # to create the grouping component of the Directive.
          #
          # # Handles list of grouping criteria as positional arguments
          # Select.all.group(:country, :state, :municipality)
          # => #<Select:0x000055837e273178
          #       @groupings=[
          #         { criteria: :country },
          #         { criteria: :state },
          #         { criteria: :municipality }
          #       ]
          #     >
          #
          # # Handles list of grouping criteria with custom mappings as keyword arguments
          # Select.all.group(:country, state: { apply: :sum }, municipality: { alias: :mun })
          # => #<Select:0x000055837e273178
          #       @groupings=[
          #         { criteria: :country },
          #         { criteria: :state, apply: :sum },
          #         { criteria: :municipality, alias: :mun }
          #       ]
          #     >
          def group(*items, **kwitems)
            items.each do |item|
              case item
              when Symbol, String
                criteria = item
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

          def groupings
            @groupings ||= []
          end

          private

          def grouping_indices
            @grouping_indices ||= {}
          end

          def handle_criteria(criteria)
            if (index = grouping_indices[criteria])
              groupings.delete_at(index)
              update_grouping_indices
            end

            grouping_indices[criteria] = groupings.size
            groupings.push({ criteria: criteria })
          end

          def handle_criteria_hash(criteria, hash)
            if (index = grouping_indices[criteria])
              groupings.delete_at(index)
              update_grouping_indices
            end

            grouping_indices[criteria] = groupings.size
            groupings.push(hash.merge({ criteria: criteria }))
          end

          def update_grouping_indices
            groupings.each_with_index do |grouping, index|
              grouping_indices[grouping[:criteria]] = index
            end
          end

          def invalid_criteria!
            msg = "Invalid grouping criteria provided to #group"
            raise(Persistence::Errors::OperationError, msg)
          end
        end
      end
    end
  end
end
