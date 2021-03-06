# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      # Responsible of building a COUNT Directive.
      class Count < Operation
        include Capabilities::Retriever
        include Capabilities::Filter
        include Capabilities::DiscardedManager

        def initialize(source)
          retrieve('*': { resource: source, alias: nil, aggregation: 'COUNT' })
          exclude_discarded
          super(source)
        end

        def after(results)
          return 0 if (first = results.first).nil?

          first[:count]
        end
      end
    end
  end
end
