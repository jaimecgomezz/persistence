# frozen_string_literal: true

module Persistence
  # Abstract layer that hides implementation details related to the persistence
  # layer. It has 2 main responsibilities:
  #   - Querying the DB through the Engine
  #   - Transform Engine's result to deliver it in the expected format
  #
  # Example
  #
  # class UserRepository < Repository
  # end
  #
  # user_repository = UserRespository.new
  # users_paginated = user_repository.all
  class Repository
    def initialize
      @engine = ENGINE || raise_no_engine!
      @transformer = TRANSFORMER || Transformers::UnitTransformer
    end

    def count
      engine.count.perform
    end

    def all
      items, pagination = engine.select.limit(0).paginate.perform

      transformer.many(items, pagination)
    end

    def first
      item = engine.select.limit(1).perform
      return unless item

      transformer.one(item)
    end

    def last
      item = engine.select.order(:asc).limit(1).perform
      return unless item

      transformer.one(item)
    end

    def find(id)
      item = engine.where({ id: id }).limit(1).perform
      return unless item

      transformer.one(item)
    end

    def find_many(ids, pagination = {})
      items, pagination = engine.select.where({ id: ids }).paginate(pagination).perform

      transformer.many(items, pagination)
    end

    def find_discarded(id)
      item = engine.select.include_discarded.where({ id: id }).limit(1).perform

      return unless item

      transformer.one(item)
    end

    def find_many_discarded(ids, pagination = {})
      items, pagination = engine.select.include_discarded.where({ id: ids }).paginate(pagination).perform

      transformer.many(items, pagination)
    end

    def where(filters, pagination = {})
      items, pagination = engine.select.where(filters).paginate(pagination).perform

      transformer.many(items, pagination)
    end

    def one_where(filters)
      item = engine.select.where(filters).limit(1).perform

      return unless item

      transformer.one(item)
    end

    def create(input)
      id = engine.ceate(input).perform

      return unless id

      find(id)
    end

    def bulk(inputs)
      ids = inputs.map { |input| create(input) }.compact

      find_many(ids)
    end

    def update(id, input)
      id = engine.update.where({ id: id }).to(input).perform

      return unless id

      find(id)
    end

    def update_where(filters, input)
      ids = engine.update.where(filters).to(input).perform

      find_many(ids)
    end

    def destroy(id)
      item = engine.where({ id: id }).limit(1).perform

      return unless item && engine.delete.where({ id: id }).perform

      transformer.one(item)
    end

    def destroy_where(filters)
      items, pagination = engine.select.where(filters).perform

      ids = engine.delete.where(filters)

      destroyed = items.select { |item| ids.include?(item[:id]) }

      transformer.many(destroyed, pagination)
    end

    def discard(id)
      id = engine.update.where(id).to({ deleted_at: Time.now }).perform

      return unless id

      find_discarded(id)
    end

    def discard_where(filters)
      ids = engine.update.where(filters).to({ deleted_at: Time.now }).perform

      find_many_discarded(ids)
    end

    private

    def raise_no_engine!
      msg = "No ENGINE defined for #{self}"
      raise(Persistence::Errors::RepositoryError, msg)
    end
  end
end
