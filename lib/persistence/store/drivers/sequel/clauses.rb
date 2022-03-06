# frozen_string_literal: true

module Persistence
  module Store
    module Drivers
      module Sequel
        # Contains classes specialized in building specif clauses for an SQL
        # statement.
        module Clauses
        end
      end
    end
  end
end

require_relative 'clauses/with'
require_relative 'clauses/select'
