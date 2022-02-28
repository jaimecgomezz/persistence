# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      module Capabilities
        # Makes the Operation capable of being filtered by specific criteria.
        module Filterable
          def where(filters = nil); end
        end
      end
    end
  end
end
