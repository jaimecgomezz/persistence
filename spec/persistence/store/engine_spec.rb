# frozen_string_literal: true

RSpec.describe Persistence::Store::Engine do
  let(:fetch) { [] }
  let(:db) { Sequel.mock(fetch: fetch) }
  let(:driver) { Persistence::Store::Drivers::Sequel::Postgres.new(db: db) }
  let(:mocker) { described_class.new(:users, driver) }

  it 'is capable of initializing a supported operation' do
    initializer = Persistence::Store::Engine::OPERATIONS.keys.shuffle.first
    operation = Persistence::Store::Engine::OPERATIONS[initializer]

    expect(mocker.send(initializer)).to be(mocker)
    expect(mocker.operation).to be_a(operation)
  end

  it 'is capable of proxying methods to initialized operation' do
    expect(mocker.selection.where({ id: 1 })).to be(mocker)
  end

  it 'raises exception when trying to #perform without an initialized operation' do
    expect do
      mocker.perform
    end.to raise_error(Persistence::Errors::EngineError, "Can't #perform when no operation has been selected")
  end

  it 'raises exception when proxying method not supported by the initialized operation' do
    expect do
      mocker.selection.whatever
    end.to raise_error(Persistence::Errors::EngineError, "The select operation doesn't implements #whatever")
  end

  it 'raises exception when initializing an unsupported operation' do
    expect do
      mocker.whatever
    end.to raise_error(Persistence::Errors::EngineError, "The operation whatever isn't supported")
  end

  describe '#perform' do
    context 'with successful execution' do
      let(:fetch) { [{ id: 1 }] }
      let(:result) { mocker.selection.where({ id: 1 }).limit(1).perform }

      it 'returns expected result' do
        expect(result).to match(fetch.first)
      end

      it 'clean operation when done' do
        mocker.selection.perform
        expect(mocker.operation).to be_nil
      end
    end

    context 'with exception during execution' do
      let(:fetch) { StandardError }

      it 'handles exception' do
        expect do
          mocker.selection.where({ id: 'ERROR' }).limit(1).perform
        end .to raise_error(Persistence::Errors::DriverError, 'StandardError: StandardError')
      end
    end

    context 'with invalid driver' do
      let(:driver) { Class.new.new }

      it 'raises exception' do
        expect do
          mocker.selection.perform
        end.to raise_error(Persistence::Errors::EngineError, "Invalid driver, it should implement #run(operation)")
      end
    end
  end

  describe '#perform_custom' do
    let(:db) { Sequel.mock(fetch: fetch) }

    context 'with successful execution' do
      let(:id) { uuid }
      let(:fetch) { { id: id } }

      let(:result) { mocker.perform_custom("SELECT * FROM users WHERE id = :id", { id: id }) }

      it 'returns expected result' do
        expect(result.first).to match(fetch)
      end
    end

    context 'with exception during execution' do
      let(:fetch) { StandardError }

      it 'handles exception' do
        expect do
          mocker.perform_custom("SELECT * FROM users WHERE id = :id", { id: 1 })
        end .to raise_error(Persistence::Errors::DriverError)
      end
    end

    context 'with invalid driver' do
      let(:driver) { Class.new.new }

      it 'raises exception' do
        expect do
          mocker.perform_custom("", {})
        end.to raise_error(Persistence::Errors::EngineError, "Invalid driver, it should implement #run_custom")
      end
    end
  end
end
