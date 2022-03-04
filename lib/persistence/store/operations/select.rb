# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      # Responsible of building a READ Directive.
      class Select < Operation
        include Capabilities::Filter
        include Capabilities::Aggregator
        include Capabilities::Retriever
        include Capabilities::Orderer
        include Capabilities::Differentiator
        include Capabilities::Grouper

        # Pending
        include Capabilities::Joiner
        include Capabilities::Requirer
        include Capabilities::Paginator
        include Capabilities::Preloader
      end
    end
  end
end
