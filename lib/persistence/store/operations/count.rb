# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      # Responsible of building a COUNT Directive.
      class Count < Operation
        include Capabilities::Filter
        include Capabilities::DiscardedManager

        def initialize(source)
          exclude_discarded
          super(source)
        end
      end
    end
  end
end
