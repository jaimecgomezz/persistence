# frozen_string_literal: true

module Persistence
  module Store
    module Drivers
      module Sequel
        # Base Sequel driver.
        class Driver
          attr_reader :db

          def initialize(db:)
            @db = db
          end

          def run(operation)
            statement, params = send(operation.name, operation)
            db.fetch(statement, params)
          rescue NoMehodError => e
            msg = case e
                  when 'fetch'
                    "Invalid DB provided to #{self.class}, it should implement #fetch(sql, *args)"
                  else
                    "#{self.class} doesn't supports the :#{operation.name} operation"
                  end
            raise(Persistence::Errors::DriverError, msg)
          end

          private

          def count(_operation)
            raise_missing_implementation!(:count)
          end

          def select(_operation)
            raise_missing_implementation!(:select)
          end

          def delete(_operation)
            raise_missing_implementation!(:delete)
          end

          def update(_operation)
            raise_missing_implementation!(:update)
          end

          def create(_operation)
            raise_missing_implementation!(:create)
          end

          def raise_missing_implementation!(name)
            msg = "#{self.class} hasn't implemented the :#{name} operation"
            raise(Persistence::Errors::DriverError, msg)
          end
        end
      end
    end
  end
end
