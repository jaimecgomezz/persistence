# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      # Contains modules that allow an Operation to extend its behaviour.
      module Capabilities
      end
    end
  end
end

require_relative 'capabilities/reactioner'
require_relative 'capabilities/sourcer'
require_relative 'capabilities/helpers'
require_relative 'capabilities/filter'
require_relative 'capabilities/joiner'
require_relative 'capabilities/orderer'
require_relative 'capabilities/paginator'
require_relative 'capabilities/preloader'
require_relative 'capabilities/requirer'
require_relative 'capabilities/aggregator'
require_relative 'capabilities/differentiator'
require_relative 'capabilities/grouper'
require_relative 'capabilities/retriever'
require_relative 'capabilities/setter'
