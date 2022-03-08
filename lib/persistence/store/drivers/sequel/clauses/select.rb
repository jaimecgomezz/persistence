# frozen_string_literal: true

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

            attr_reader :operation, :params

            def initialize(operation, params)
              @operation = operation
              @params = params
            end

            def build
              return ["", params] if (retrievables = operation.retrievables.to_a).empty?

              first, *rest = retrievables
              retrievables_formatted = rest.each_with_object([format_retrievable(first)]) do |retrievable, acc|
                acc << format_retrievable(retrievable)
              end.join(", ")

              statement = [clause_constant, format_distinctiveness, retrievables_formatted].select do |e|
                !e.empty?
              end.join(" ")

              [statement, params]
            rescue NoMethodError
              msg = "The Operation isn't a Retriever"
              raise(Persistence::Errors::DriverError, msg)
            end

            private

            def clause_constant
              "SELECT"
            end

            def format_distinctiveness
              return "" if (distincts = operation.distincts).empty?

              first, *rest = distincts
              distincts_formatted = rest.each_with_object([first[:criteria]]) do |distinct, acc|
                acc << distinct[:criteria]
              end.join(", ")

              ["DISTINCT", distincts_formatted].join(" ")
            rescue NoMethodError
              msg = "The Operation isn't a Differentiator"
              raise(Persistence::Errors::DriverError, msg)
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
          end
        end
      end
    end
  end
end
