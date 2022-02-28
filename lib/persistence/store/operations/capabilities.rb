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

require_relative 'capabilities/filterable'
require_relative 'capabilities/joinable'
require_relative 'capabilities/paginatable'
require_relative 'capabilities/preloadable'
require_relative 'capabilities/requirable'
