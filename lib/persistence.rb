# frozen_string_literal: true

require 'hanami/utils/hash'

# Persistence namespace
module Persistence
end

require_relative 'persistence/config'
require_relative 'persistence/store'
require_relative 'persistence/transformers'
require_relative 'persistence/repository'
require_relative 'persistence/errors'
require_relative 'persistence/model'
require_relative 'persistence/entity'
