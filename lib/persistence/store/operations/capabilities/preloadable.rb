# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      module Capabilities
        # Makes the Operation capable of being preloaded with associations.
        module Preloadable
          def preload(associations); end
        end
      end
    end
  end
end
