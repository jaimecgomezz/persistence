# frozen_string_literal: true

module Persistence
  module Store
    module Drivers
      module Sequel
        # Class that transforms a Operation into Directives that can be executed
        # by the Sequel::Postgres Driver.
        class Postgres < Driver
        end
      end
    end
  end
end
