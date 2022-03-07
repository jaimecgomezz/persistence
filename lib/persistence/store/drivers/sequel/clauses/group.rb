module Persistence
  module Store
    module Drivers
      module Sequel
        module Clauses
          # Class that specializes in building SQL's GROUP clause.
          class Group
            attr_reader :operation, :params

            def initialize(operation, params)
              @operation = operation
              @params = params
            end

            def build
              return ["", params] if (groupings = operation.groupings).empty?

              first, *rest = groupings
              groups_formatted = rest.each_with_object([first[:criteria]]) do |grouping, acc|
                acc << grouping[:criteria]
              end.join(", ")

              [["GROUP BY", groups_formatted].join(" "), params]
            rescue NoMethodError
              msg = "The Operation provided isn't a Grouper"
              raise(Persistence::Errors::DriverError, msg)
            end
          end
        end
      end
    end
  end
end
