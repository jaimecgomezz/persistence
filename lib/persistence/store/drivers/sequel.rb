# frozen_string_literal: true

module Persistence
  module Store
    module Drivers
      # Contains Sequel drivers, each one specialized to handle an specific
      # database.
      module Sequel
      end
    end
  end
end

require_relative 'sequel/driver'
require_relative 'sequel/postgres'
