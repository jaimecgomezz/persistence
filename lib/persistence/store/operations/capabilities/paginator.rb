# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      module Capabilities
        # Makes the Operation capable of paginating and limiting results.
        module Paginator
          def limit(size)
          end

          def offset(size)
          end

          def paginate
          end
        end
      end
    end
  end
end
