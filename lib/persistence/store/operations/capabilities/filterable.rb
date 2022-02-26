# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      module Capabilities
        # Makes the Operation capable of being filtered by specific criteria.
        module Filterable
          def where(filters); end

          def where_not(filters); end

          def and(filters); end

          def or(filters); end
        end
      end
    end
  end
end
