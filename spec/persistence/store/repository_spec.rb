# frozen_string_literal: true

RSpec.describe Persistence::Repository do
  let(:engine) do
    Persistence::Store::Engine.new(
      :users,
      Persistence::Store::Drivers::Sequel::Postgres.new(db: Sequel.mock(fetch: fetch))
    )
  end

  let(:repository) { described_class.new(engine) }

  describe '.new' do
    let(:fetch) { [] }

    it 'expects engine and driver' do
      expect(described_class).to respond_to(:new).with(2).arguments
    end

    it 'uses the unit transformer by default' do
      expect(repository.transformer).to be_a(Persistence::Transformers::UnitTransformer)
    end
  end

  describe '#count' do
    let(:fetch) { [{ count: 10 }] }
    let(:result) { repository.count }

    it 'returns count' do
      expect(result).to be(10)
    end
  end

  describe '#count_where' do
    let(:fetch) { [{ count: 1 }] }
    let(:result) { repository.count_where({ id: 1 }) }

    it 'returns count' do
      expect(result).to be(1)
    end
  end

  describe '#all' do
    let(:fetch) { [{ id: 1 }, { id: 2 }] }
    let(:result) { repository.all }

    it 'returns all records' do
      expect(result).to match(fetch)
    end
  end

  describe '#first' do
    let(:fetch) { [{ id: 1 }] }
    let(:result) { repository.first }

    it 'returns first record' do
      expect(result).to match(fetch.first)
    end
  end

  describe '#last' do
    let(:fetch) { [{ id: 2 }] }
    let(:result) { repository.last }

    it 'returns last record' do
      expect(result).to match(fetch.last)
    end
  end

  describe '#find' do
    let(:fetch) { [{ id: 1 }] }
    let(:result) { repository.find(1) }

    it 'returns record with id' do
      expect(result).to match(fetch.first)
    end
  end

  describe '#find_many' do
    let(:fetch) { [{ id: 1 }, { id: 2 }] }
    let(:result) { repository.find_many(1, 2) }

    it 'returns records with ids' do
      expect(result).to match(fetch)
    end
  end

  describe '#find_discarded' do
    let(:fetch) { [{ id: 1 }] }
    let(:result) { repository.find_discarded(1) }

    it 'returns discarded record with id' do
      expect(result).to match(fetch.first)
    end
  end

  describe '#find_many_discarded' do
    let(:fetch) { [{ id: 1 }, { id: 2 }] }
    let(:result) { repository.find_many_discarded(1, 2) }

    it 'returns discarded records with ids' do
      expect(result).to match(fetch)
    end
  end

  describe '#find_where' do
    let(:fetch) { [{ id: 1, org: 1 }, { id: 2, org: 1 }] }
    let(:result) { repository.find_where({ org: 1 }) }

    it 'returns first matching record' do
      expect(result).to match(fetch.first)
    end
  end

  describe '#find_many_where' do
    let(:fetch) { [{ id: 1, org: 1 }, { id: 2, org: 1 }] }
    let(:result) { repository.find_many_where({ org: 1 }) }

    it 'returns matching records' do
      expect(result).to match(fetch)
    end
  end

  describe '#create' do
    let(:fetch) { [{ id: 1 }] }
    let(:result) { repository.create({ id: 1 }) }

    it 'returns record created' do
      expect(result).to match(fetch.first)
    end
  end

  describe '#bulk' do
    let(:fetch) { [[{ id: 1 }], [{ id: 2 }]] }
    let(:result) { repository.bulk([{ id: 1 }, { id: 2 }]) }

    it 'returns created records' do
      expect(result).to match([{ id: 1 }, { id: 2 }])
    end
  end

  describe '#update' do
    let(:fetch) { [{ id: 2 }] }
    let(:result) { repository.update(1, { id: 2 }) }

    it 'returns updated record' do
      expect(result).to match(fetch.first)
    end
  end

  describe '#update_where' do
    let(:fetch) { [{ id: 1, name: 'updated' }] }
    let(:result) { repository.update_where({ id: 1 }, { name: 'updated' }) }

    it 'returns record updated' do
      expect(result).to match(fetch.first)
    end
  end

  describe '#destroy' do
    let(:fetch) { [{ id: 1 }] }
    let(:result) { repository.destroy(1) }

    it 'returns destroyed records' do
      expect(result).to match(fetch.first)
    end
  end

  describe '#destroy_many' do
    let(:fetch) { [{ id: 1 }, { id: 2 }] }
    let(:result) { repository.destroy_many(1, 2) }

    it 'returns destroyed records' do
      expect(result).to match(fetch)
    end
  end

  describe '#destroy_where' do
    let(:fetch) { [{ id: 1, name: 'Luis' }, { id: 2, name: 'Luis' }] }
    let(:result) { repository.destroy_where({ name: 'Luis' }) }

    it 'returns destroyed records' do
      expect(result).to match(fetch)
    end
  end

  describe '#discard' do
    let(:fetch) { [{ id: 1, deleted_at: Time.now.utc.to_s }] }
    let(:result) { repository.discard(1) }

    it 'returns discarded record' do
      expect(result).to match(fetch.first)
    end
  end

  describe '#discard_many' do
    let(:fetch) { [{ id: 1, deleted_at: Time.now.utc.to_s }, { id: 2, deleted_at: Time.now.utc.to_s }] }
    let(:result) { repository.discard_many(1, 2) }

    it 'returns discarded records' do
      expect(result).to match(fetch)
    end
  end

  describe '#discard_where' do
    let(:now) { Time.now.utc.to_s }
    let(:fetch) { [{ id: 1, name: 'Luis', deleted_at: now }, { id: 2, name: 'Luis', deleted_at: now }] }
    let(:result) { repository.discard_where({ name: 'Luis' }) }

    it 'returns' do
      expect(result).to match(fetch)
    end
  end
end
