# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      module Capabilities
        # Makes the Operation capable of returning distinc results.
        module Differentiator
          # Defines a @distincts instance variable which is a descriptive hash
          # that should later be understood by the Driver in order to build
          # query's distinctiveness criteria.
          #
          # # Handles a list of criteria as positional arguments and the use of
          # :on as a postgres-specific keyword argument
          # Select.all.distinct(:country, :state, :municipality, on: :country)
          # => #<Select:0x000055837e273178
          #       @distincts={
          #         on: :country,
          #         distincts: [:country, :state, :municipality]
          #       }
          #     >
          def distinct(*items, on: nil)
            criterias = []

            items.map do |criteria|
              case criteria
              when Symbol, String
                criterias << criteria
              else
              end
            end

            distincts[:on] = on
            distincts[:distincts] = criterias

            self
          end

          def distincts
            @distincs ||= { on: nil, distincts: [] }
          end
        end
      end
    end
  end
end
