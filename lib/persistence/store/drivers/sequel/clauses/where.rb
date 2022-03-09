# frozen_string_literal: true

module Persistence
  module Store
    module Drivers
      module Sequel
        module Clauses
          # Class specialized in building SQL's WHERE clause.
          #
          # TODO: improve readability and codebase in general
          class Where
            attr_reader :operation, :params, :filter_id

            def initialize(operation, params)
              @operation = operation
              @params = params
              @filter_id = 'a'
            end

            def build
              ufilters, gfilters = operation.user_filters, operation.global_filters
              return ["", params] if ufilters.empty? && ufilters.empty?

              statement = [
                "WHERE",
                format_ufilters(ufilters),
                format_gfilters(gfilters)
              ].compact.join(" ")

              [statement, params]
            rescue NoMethodError
              msg = "The Operation isn't a Filter"
              raise(Persistence::Errors::DriverError, msg)
            end

            private

            def format_ufilters(filters)
              return if filters.empty?

              first, *rest = filters
              first = format_filters_container(first[:filters], first[:negate])
              filters_formatted = rest.each_with_object([first]) do |filter, acc|
                operand = filter[:operand].to_s.upcase
                acc << [operand, format_filters_container(filter[:filters], filter[:negate])].join(" ")
              end.join(" ")

              ["(", filters_formatted, ")"].join
            end

            def format_gfilters(filters)
              return if filters.empty?

              ["AND", format_filters_container(filters, false)].join(" ")
            end

            def format_filters_container(container, negate)
              return if (filters = container.to_a).empty?

              first, *rest = filters
              filters_formatted = rest.each_with_object([format_filter(first)]) do |filter, acc|
                acc << ["AND", format_filter(filter)].join(" ")
              end.join(" ")

              @filter_id = filter_id.next

              statement = ["(", filters_formatted, ")"].join

              negate ? ["NOT", statement].join(" ") : statement
            end

            def format_filter(field)
              field, value = field

              placeholder = ["where_", filter_id, "_", field].join

              case value
              when Array
                params[placeholder.to_sym] = value
                [field, "IN", [":", placeholder].join].join(" ")
              when Range
                placeholder_first = [placeholder, "_first"].join
                placeholder_last = [placeholder, "_last"].join

                params[placeholder_first.to_sym] = format_time(value.first)
                params[placeholder_last.to_sym] = format_time(value.last)
                [
                  field, "BETWEEN", [":", placeholder_first].join, "AND",
                  [":", placeholder_last].join
                ].join(" ")
              when Hash
                return if (flattened = flatten_hash(value).to_a).empty?

                flattened.each_with_object([]) do |pairs, acc|
                  acc << format_flattened_pair(field, placeholder, pairs)
                end.join(" AND ")
              when Time
                params[placeholder.to_sym] = format_time(value)
                [field, '=', [":", placeholder].join].join(" ")
              when Persistence::Store::Operations::Operation
                msg = "Operations as filters aren't supportted yet"
                raise(Persistence::Errors::DriverError, msg)
              else
                params[placeholder.to_sym] = value
                [field, "=", [":", placeholder].join].join(" ")
              end
            end

            def flatten_hash(hash)
              hash.each_with_object({}) do |(k, v), h|
                if v.is_a? Hash
                  flatten_hash(v).map do |h_k, h_v|
                    h["#{k}__#{h_k}".to_sym] = h_v
                  end
                else
                  h[k] = v
                end
              end
            end

            def format_flattened_pair(field, placeholder, pair)
              kpath, value = pair
              placeholder_nested = [placeholder, "__", kpath].join
              params[placeholder_nested.to_sym] = value

              *firsts, last = kpath.to_s.split("__")

              path = [[field, *firsts].join(" -> "), last].join(" ->> ")
              [path, "=", [":", placeholder_nested].join].join(" ")
            end

            def format_time(time)
              return time unless time.is_a?(Time)

              time.utc.to_s
            end
          end
        end
      end
    end
  end
end
