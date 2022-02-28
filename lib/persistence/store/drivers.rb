# frozen_string_literal: true

module Persistence
  module Store
    # Contains classes that its unique responsability is to support the
    # translation of any of the available Operations into the specic query that
    # the DB requires.
    module Drivers
    end
  end
end

require_relative 'drivers/sequel'
