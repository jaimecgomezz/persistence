# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      module Capabilities
        # Makes the Operation capable of preloading associations into the final
        # result.
        module Preloader
          def preload(associations); end
        end
      end
    end
  end
end
