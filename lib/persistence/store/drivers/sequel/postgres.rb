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

          def build(operation)
            send(operation.name, operation)
          rescue NoMethodError => e
            handle_no_method_error!(e.name)
          end

          def run(operation)
            statement, params = send(operation.name, operation)
            results = db.fetch(statement, params).all
            operation.after(results)
          rescue NoMethodError => e
            handle_no_method_error!(e.name)
          rescue => e
            raise(Persistence::Errors::DriverError, e.message)
          end

          def run_custom(statement, params)
            db.fetch(statement, params).all
          rescue NoMethodError => e
            handle_no_method_error!(e.name)
          rescue => e
            raise(Persistence::Errors::DriverError, e.message)
          end

          private

          def select(operation)
            build_statement(
              operation,
              [
                Clauses::With,
                Clauses::Select,
                Clauses::From,
                Clauses::Where,
                Clauses::Group,
                Clauses::Order,
                Clauses::Limit,
                Clauses::Offset
              ]
            )
          end

          def delete(operation)
            build_statement(
              operation,
              [
                Clauses::Delete,
                Clauses::Where,
                Clauses::Returning
              ]
            )
          end

          def update(operation)
            build_statement(
              operation,
              [
                Clauses::Update,
                Clauses::Set,
                Clauses::Where,
                Clauses::Returning
              ]
            )
          end

          def insert(operation)
            build_statement(
              operation,
              [
                Clauses::Insert,
                Clauses::Values,
                Clauses::Returning
              ]
            )
          end

          def count(operation)
            build_statement(
              operation,
              [
                Clauses::Select,
                Clauses::From,
                Clauses::Where
              ]
            )
          end

          alias_method :discard, :update

          def build_statement(operation, clauses)
            Builder.new(operation, clauses).build
          end

          def handle_no_method_error!(name)
            msg = case name
                  when 'fetch'
                    "Invalid :db provided, it should implement #fetch(sql, params)"
                  when 'name', 'after'
                    "Invalid Operation provided, should implement ##{name}"
                  else
                    "The ##{name} operation isn't supported by the driver"
                  end

            raise(Persistence::Errors::DriverError, msg)
          end
        end
      end
    end
  end
end
