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
            clear_grouper_configuration

            items.each do |item|
              case item
              when Symbol, String
                criteria = item
                handle_grouping_criteria(criteria)
              else
                invalid_grouping_criteria!(criteria)
              end
            end

            kwitems.each do |criteria, mapping|
              case mapping
              when Hash
                handle_grouping_mapping(criteria, mapping)
              else
                invalid_grouping_criteria!(criteria)
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

          def handle_grouping_criteria(criteria)
            groupings.push({ criteria: criteria })
          end

          def handle_grouping_mapping(criteria, mapping)
            groupings.push(mapping.merge({ criteria: criteria }))
          end

          def clear_grouper_configuration
            @groupings = []
            @grouping_indices = {}
          end

          def invalid_grouping_criteria!(sample)
            msg = "Invalid grouping criteria provided to #group: #{sample}"
            raise(Persistence::Errors::OperationError, msg)
          end
        end
      end
    end
  end
end
