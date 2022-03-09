# frozen_string_literal: true

module Persistence
  module Store
    module Drivers
      module Sequel
        module Clauses
          # Class specialized in building SQL's WHERE clause.
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
              filters_formatted = rest.each_with_object([format_filters_container(first[:filters])]) do |filter, acc|
                acc << [
                  format_filter_operand(filter[:operand], filter[:negate]),
                  format_filters_container(filter[:filters])
                ].compact.join(" ")
              end.join(" ")

              ["(", filters_formatted, ")"].join
            end

            def format_gfilters(filters)
              return if filters.empty?

              [format_filter_operand(:and, false), format_filters_container(filters)].join(" ")
            end

            def format_filters_container(filters)
              return if (filters = filters.to_a).empty?

              first, *rest = filters
              filters_formatted = rest.each_with_object([format_filter(first)]) do |filter, acc|
                acc << [
                  format_filter_operand(:and, false),
                  format_filter(filter)
                ].compact.join(" ")
              end.join(" ")

              @filter_id = filter_id.next

              ["(", filters_formatted, ")"].join
            end

            def format_filter_operand(operand, negate)
              operand = case operand
                        when :and
                          "AND"
                        when :or
                          "OR"
                        else
                          msg = "Operand in filters not supported: #{filters}"
                          raise(Persistence::Errors::DriverError, msg)
                        end

              return operand unless negate

              ["NOT", operand].join(" ")
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

                params[placeholder_first.to_sym] = value.first
                params[placeholder_last.to_sym] = value.last
                [
                  field, "BETWEEN", [":", placeholder_first].join, "AND",
                  [":", placeholder_last].join
                ].join(" ")
              when Hash
                return if (flattened = flatten_hash(value).to_a).empty?

                first, *rest = flattened
                rest.each_with_object([format_flattened_pair(field, placeholder, first)]) do |pairs, acc|
                  acc << format_flattened_kv_pair(field, placeholder, pairs)
                end.join(" AND ")
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
          end
        end
      end
    end
  end
end
