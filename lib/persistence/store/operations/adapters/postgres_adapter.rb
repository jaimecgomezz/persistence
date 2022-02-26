# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      module Adapters
        # Exposes :as_postgres
        module PostgresAdapter
          def self.adapter_method
            :as_postgres
          end

          def as_postgres
            msg = "#{self.class} operation didn't implement :as_postgres"
            raise(Persistence::Errors::AdapterError, msg)
          end
        end
      end
    end
  end
end
