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

            CASTS = {
              boolean: 'BOOLEAN',
              booleans: 'BOOLEAN[]',
              char: 'CHAR',
              chars: 'CHAR[]',
              varchar: 'VARCHAR',
              varchars: 'VARCHAR[]',
              date: 'DATE',
              dates: 'DATE[]',
              time: 'TIME',
              times: 'TIME[]',
              timestamp: 'TIMESTAMP',
              timestamps: 'TIMESTAMPS[]',
              interval: 'INTERVAL',
              intervals: 'INTERVAL[]',
              uuid: 'UUID',
              uuids: 'UUID[]',
              json: 'JSON',
              jsons: 'JSON[]',
              jsonb: 'JSONB',
              jsonbs: 'JSONB[]'
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
              statement << "SELECT "
              statement << format_distinctiveness
              statement << format_retrievable(first)
              rest.each_with_object(statement) do |retrievable, acc|
                acc << ", #{format_retrievable(retrievable)}"
              end
            end

            private

            def format_distinctiveness
              stmnt = ""

              klass = Persistence::Store::Operations::Capabilities::Differentiator
              return stmnt unless operation.class.ancestors.include?(klass)

              return stmnt if operation.distincts.empty?

              first, *rest = operation.distincts
              stmnt << "DISTINCT "
              stmnt << "#{first[:criteria]}"
              stmnt << rest.each_with_object("") do |distinct, acc|
                acc << ", #{distinct[:criteria]}"
              end
              stmnt << " "
            end

            def format_retrievable(retrievable)
              name, hash = retrievable

              field = format_field(name, hash[:resource])
              casted = format_cast(field, hash[:cast])
              aggregated = format_aggregation(casted, hash[:aggregation])
              format_alias(aggregated, hash[:alias])
            end

            def format_field(name, resource)
              resource ||= operation.source

              "#{resource}.#{name}"
            end

            def format_cast(field, cast)
              return field unless cast

              cast = CASTS[cast.to_sym] || cast

              "#{field}::#{cast}"
            end

            def format_aggregation(field, aggregation)
              return field unless aggregation

              aggregation = AGGREGATIONS[aggregation.to_sym] || aggregation

              "#{aggregation}(#{field})"
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
