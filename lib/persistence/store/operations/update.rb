# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      # Responsible of building an UPDATE Directive.
      class Update < Operation
        include Capabilities::Filter
        include Capabilities::Retriever
        include Capabilities::Requirer

        # Pending
        include Capabilities::Setter
      end
    end
  end
end
