# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      # Responsible of building a DELETE Directive.
      class Delete < Operation
        include Capabilities::Filter
        include Capabilities::Retriever
        include Capabilities::Requirer
        include Capabilities::DiscardedManager

        def initialize(source)
          exclude_discarded
          super(source)
        end

        def after(results)
          return results unless results.size == 1

          results.first
        end
      end
    end
  end
end
