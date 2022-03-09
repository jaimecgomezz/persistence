# frozen_string_literal: true

module Persistence
  module Store
    module Drivers
      module Sequel
        module Clauses
          # Class specialized in building SQL's FROM clause.
          class From
            JOINS = {
              lj: 'LEFT JOIN',
              loj: 'LEFT OUTER JOIN',
              rj: 'RIGHT JOIN',
              roj: 'RIGHT OUTER JOIN',
              fj: 'FULL JOIN',
              foj: 'FULL OUTER JOIN'
            }.freeze

            attr_reader :operation, :params

            def initialize(operation, params)
              @operation = operation
              @params = params
            end

            def build
              base = "FROM #{operation.source}"

              return [base, params] if (joins = operation.joins.to_a).empty?

              joins_formatted = joins.each_with_object([]) do |join, acc|
                acc << format_join(join)
              end.join(" ")

              [[base, joins_formatted].join(" "), params]
            rescue NoMethodError
              msg = "The Operation doesn't has a @source"
              raise(Persistence::Errors::DriverError, msg)
            end

            private

            def format_join(join)
              name, hash = join
              kind = hash[:kind]

              join_kind = JOINS[kind] || kind
              join_match = "#{operation.source}.#{hash[:left]} = #{name}.#{hash[:right]}"

              "#{join_kind} ON #{join_match}"
            end
          end
        end
      end
    end
  end
end
