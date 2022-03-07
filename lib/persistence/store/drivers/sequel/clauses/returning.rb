module Persistence
  module Store
    module Drivers
      module Sequel
        module Clauses
          class Returning < Select
            private

            def clause_constant
              "RETURNING"
            end
          end
        end
      end
    end
  end
end
