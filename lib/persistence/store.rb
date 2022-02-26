# frozen_string_literal: true

module Persistence
  # Contains the Engine, who acts as a proxy for the concrete operations also
  # contained within Store.
  module Store
  end
end

require_relative 'store/operations'
require_relative 'store/engine'
