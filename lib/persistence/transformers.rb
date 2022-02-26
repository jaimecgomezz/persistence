# frozen_string_literal: true

module Persistence
  # Contains classes responsible of transforming Engine's results into the
  # expected format.
  #
  # The should expose 2 methods:
  #
  # #one
  # Responsible for the transformation of a single item
  #
  # #many(items, pagination = {})
  # Responsible for the transformation of a list of items along with its
  # pagination
  #
  # Example
  #
  # class User
  #   attr_accessor :id
  # end
  #
  # user_repository = UserRepository.new
  # user_transformer = Transformer.new(User)
  #
  # user = user_transformer.one(user_repository.first)
  # users = user_transformer.many(user_repository.all)
  module Transformers
  end
end

require_relative 'transformers/unit_transformer'
require_relative 'transformers/setter_transformer'
require_relative 'transformers/initializer_transformer'
