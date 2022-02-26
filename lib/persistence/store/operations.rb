# frozen_string_literal: true

module Persistence
  module Store
    # Contains classes that are responsible of building the Directive that will
    # be later be executed by the Driver.
    module Operations
    end
  end
end

require_relative 'operations/adapters'
require_relative 'operations/capabilities'
require_relative 'operations/base_operation'
require_relative 'operations/select_operation'
require_relative 'operations/delete_operation'
require_relative 'operations/update_operation'
require_relative 'operations/create_operation'
require_relative 'operations/count_operation'
