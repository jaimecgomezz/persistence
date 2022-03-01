# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      module Capabilities
        # Makes the Operation capable of being paginated.
        module Paginator
          def paginate(kind); end
        end
      end
    end
  end
end
