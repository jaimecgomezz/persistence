# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      # Responsible of building a COUNT Directive.
      class Count < Operation
        include Capabilities::Filter
      end
    end
  end
end
