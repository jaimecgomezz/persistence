# frozen_string_literal: true

module Persistence
  module Store
    module Drivers
      module Sequel
        # Class specialized in building and joining the clauses provided at its
        # initialization.
        class Builder
          attr_reader :operation, :clauses

          def initialize(operation, clauses)
            @operation = operation
            @clauses = clauses
          end

          def build
            params = {}

            return ["", params] if clauses.empty?

            statement = clauses.each_with_object([]) do |clause, acc|
              stmnt, params = clause.new(operation, params).build
              acc << stmnt
            end.join(" ")

            [statement, params]
          end
        end
      end
    end
  end
end
