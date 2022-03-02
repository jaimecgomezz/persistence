# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      # Responsible of building a READ Directive.
      class Select < Operation
        include Capabilities::Filter
        include Capabilities::Requirer
        include Capabilities::Preloader
        include Capabilities::Differentiator
        include Capabilities::Aggregator
        include Capabilities::Grouper
        include Capabilities::Joiner
        include Capabilities::Orderer
        include Capabilities::Paginator
        include Capabilities::Retriever
      end
    end
  end
end
