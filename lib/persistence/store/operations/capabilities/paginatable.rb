# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      module Capabilities
        # Makes the Operation capable of being paginated.
        module Paginatable
          def limit(size); end

          def offset(size); end
        end
      end
    end
  end
end
