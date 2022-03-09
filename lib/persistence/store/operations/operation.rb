# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      # Defines the basic Operation structure and behaviour.
      class Operation
        attr_reader :source

        def initialize(source)
          @source = source
        end

        def name
          @name ||= self.class.name.to_s.split(/(?=[A-Z])/).join('_').downcase.to_sym
        end

        def after(result)
          result
        end
      end
    end
  end
end
