# frozen_string_literal: true

module Persistence
  module Store
    # Contains classes that are responsible of building the Directive that will
    # be later be executed by the Driver.
    module Operations
    end
  end
end

require_relative 'operations/capabilities'
require_relative 'operations/operation'
require_relative 'operations/select'
require_relative 'operations/delete'
require_relative 'operations/update'
require_relative 'operations/insert'
require_relative 'operations/count'
