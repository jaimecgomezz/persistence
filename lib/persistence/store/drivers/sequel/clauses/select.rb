module Persistence
  module Store
    module Drivers
      module Sequel
        module Clauses
          class Select
            AGGREGATIONS = {
              array_agg: 'ARRAY_AGG',
              avg: 'AVG',
              bit_and: 'BIT_AND',
              bit_or: 'BIT_OR',
              bool_and: 'BOOL_AND',
              bool_or: 'BOOL_OR',
              count: 'COUNT',
              every: 'EVERY',
              json_agg: 'JSON_AGG',
              jsonb_agg: 'JSONB_AGG',
              json_object_agg: 'JSON_OBJECT_AGG',
              jsonb_object_agg: 'JSONB_OBJECT_AGG',
              max: 'MAX',
              min: 'MIN',
              string_agg: 'STRING_AGG',
              sum: 'SUM',
              xmlagg: 'XMLAGG'
            }

            attr_reader :operation

            def initialize(operation)
              invalid_retriever! unless valid_retriever?(operation)

              @operation = operation
            end

            def build
              statement = ""

              return statement if (retrievables = operation.retrievables.to_a).empty?

              first, *rest = retrievables
              statement << "SELECT #{format_retrievable(first)}"
              rest.each_with_object(statement) do |retrievable, acc|
                acc << ", #{format_retrievable(retrievable)}"
              end
            end

            private

            def format_retrievable(retrievable)
              name, hash = retrievable

              field = format_field(name, hash[:resource])
              aggregated = format_aggregation(field, hash[:aggregation])
              format_alias(aggregated, hash[:alias])
            end

            def format_field(name, resource)
              return name unless resource

              "#{resource}.#{name}"
            end

            def format_aggregation(field, aggregation)
              agg = AGGREGATIONS[aggregation] || aggregation
              return field unless agg

              "#{agg}(#{field})"
            end

            def format_alias(field, aka)
              return field unless aka

              "#{field} AS #{aka}"
            end

            def valid_retriever?(operation)
              klass = Persistence::Store::Operations::Capabilities::Retriever
              operation.class.ancestors.include?(klass)
            end

            def invalid_retriever!
              msg = "The Operation provided isn't a Retriever"
              raise(Persistence::Errors::DriverError, msg)
            end
          end
        end
      end
    end
  end
end
