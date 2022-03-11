# frozen_string_literal: true

module Persistence
  # Abstract layer that hides implementation details related to the persistence
  # layer. It has 2 main responsibilities:
  #   - Querying the DB through the Engine
  #   - Transform Engine's result into the expected format using the Transformer
  #
  # Example
  #
  # class UserRepository < Repository
  # end
  #
  # user_repository = UserRespository.new
  # users_paginated = user_repository.all
  class Repository
    attr_reader :engine, :transformer

    def initialize(engine, transformer = nil)
      @engine = engine
      @transformer = transformer || Transformers::IdentityTransformer.new
    end

    def count
      engine.count.perform
    end

    def count_where(filters)
      engine.count.where(filters).perform
    end

    def all
      transformer.many(engine.selection.perform)
    end

    def first
      transformer.one(engine.selection.limit(1).perform)
    end

    def last
      transformer.one(engine.selection.order(:desc).limit(1).perform)
    end

    def find(id)
      transformer.one(engine.selection.where({ id: id }).limit(1).perform)
    end

    def find_many(*ids)
      transformer.many(engine.selection.where({ id: ids }).perform)
    end

    def find_discarded(id)
      transformer.one(engine.selection.include_discarded.where({ id: id }).limit(1).perform)
    end

    def find_many_discarded(*ids)
      transformer.many(engine.selection.include_discarded.where({ id: ids }).perform)
    end

    def find_where(filters)
      transformer.one(engine.selection.where(filters).limit(1).perform)
    end

    def find_many_where(filters)
      transformer.many(engine.selection.where(filters).perform)
    end

    def create(input)
      transformer.one(engine.insert.set(input).perform)
    end

    def bulk(inputs)
      inputs.map do |input|
        create(input)
      end.compact
    end

    def update(id, input)
      transformer.one(engine.update.where({ id: id }).set(input).perform)
    end

    def update_where(filters, input)
      transformer.many(engine.update.where(filters).set(input).perform)
    end

    def destroy(id)
      transformer.one(engine.delete.include_discarded.where({ id: id }).perform)
    end

    def destroy_many(*ids)
      transformer.many(engine.delete.include_discarded.where({ id: ids }).perform)
    end

    def destroy_where(filters)
      transformer.many(engine.delete.include_discarded.where(filters).perform)
    end

    def discard(id)
      transformer.one(engine.discard.where({ id: id }).perform)
    end

    def discard_many(*ids)
      transformer.many(engine.discard.where({ id: ids }).perform)
    end

    def discard_where(filters)
      transformer.many(engine.discard.where(filters).perform)
    end
  end
end
