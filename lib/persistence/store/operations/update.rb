# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      # Responsible of building an UPDATE Directive.
      class Update < Operation
        include Capabilities::Filter
        include Capabilities::Retriever
        include Capabilities::Requirer
        include Capabilities::Setter
        include Capabilities::DiscardedManager
      end
    end
  end
end
