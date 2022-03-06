# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      module Capabilities
        # Makes the Operation capable of including results.
        module DiscardedManager
          include Filter

          # Removes filters that exclude discarded attributes
          def include_discarded
            global_filters.delete(discard_attribute)

            self
          end

          # Adds filters that exclude discarded attributes
          def exclude_discarded
            global_filters[discard_attribute] = nil

            self
          end

          private

          def discard_attribute
            Persistence::Config::DISCARD_ATTRIBUTE
          end
        end
      end
    end
  end
end
