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

require_relative 'capabilities/filter'
require_relative 'capabilities/joiner'
require_relative 'capabilities/paginator'
require_relative 'capabilities/preloader'
require_relative 'capabilities/requirer'
