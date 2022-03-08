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
require_relative 'clauses/from'
require_relative 'clauses/group'
require_relative 'clauses/order'
require_relative 'clauses/limit'
require_relative 'clauses/offset'
require_relative 'clauses/returning'
require_relative 'clauses/delete'
require_relative 'clauses/update'
require_relative 'clauses/insert'
require_relative 'clauses/on_conflict'
require_relative 'clauses/set'
