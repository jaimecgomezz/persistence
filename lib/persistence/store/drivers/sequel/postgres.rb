# frozen_string_literal: true

module Persistence
  module Store
    module Drivers
      module Sequel
        # Class that transforms a Operation into Directives that can be executed
        # by the Sequel::Postgres Driver.
        class Postgres
          attr_reader :db

          def initialize(db:)
            @db = db
          end

          def run_custom(statement, params)
            db.fetch(statement, params).all
          rescue NoMethodError
            invalid_db!
          rescue => e
            raise(Persistence::Errors::DriverError, e.message)
          end

          private

          def invalid_db!
            msg = "Invalid :db provided to #{self.class.name}, should implement #fetch(sql, params)"
            raise(Persistence::Errors::DriverError, msg)
          end
        end
      end
    end
  end
end
