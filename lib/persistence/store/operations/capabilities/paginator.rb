# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      module Capabilities
        # Makes the Operation capable of paginating and limiting results.
        module Paginator
          include Orderer

          def offset(n = 0)
            invalid_pagination_number!(:offset, n) unless valid_pagination_number?(n)

            pagination[:offset] = n

            self
          end

          def limit(n = Persistence::Config::PAGE_SIZE)
            invalid_pagination_number!(:limit, n) unless valid_pagination_number?(n)

            pagination[:limit] = n

            self
          end

          def first(n = Persistence::Config::PAGE_SIZE)
            invalid_pagination_number!(:first, n) unless valid_pagination_number?(n)
            pagination_requires!(:order) if orderings.empty?

            @pagination = {
              offset: pagination[:offset] || 0,
              limit: n
            }

            self
          end

          def last(n = Persistence::Config::PAGE_SIZE)
            invalid_pagination_number!(:last, n) unless valid_pagination_number?(n)
            pagination_requires!(:order) if orderings.empty?

            reverse_existing_orderings!

            @pagination = {
              offset: pagination[:offset] || 0,
              limit: n
            }

            self
          end

          def paginate(**config)
            @pagination = default_pagination.merge(config)

            pagination.each do |attr, n|
              invalid_pagination_number!(:paginate, attr) unless valid_pagination_number?(n)
            end

            self
          end

          def pagination
            @pagination ||= { offset: nil, limit: nil }
          end

          private

          def default_pagination
            { offset: 0, limit: Persistence::Config::PAGE_SIZE }
          end

          def pagination_missing?(attribute)
            pagination[attribute].nil?
          end

          def valid_pagination_number?(n)
            n.is_a?(Integer) && n >= 0
          end

          def pagination_requires!(attribute)
            msg = "Pagination requires ##{attribute} to be invoked first"
            raise(Persistence::Errors::OperationError, msg)
          end

          def invalid_pagination_number!(kind, value)
            msg = "Invalid value given to ##{kind}: #{value}"
            raise(Persistence::Errors::OperationError, msg)
          end
        end
      end
    end
  end
end
