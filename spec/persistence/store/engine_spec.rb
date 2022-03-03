# frozen_string_literal: true

RSpec.describe Persistence::Store::Engine do
  let(:db) { Sequel.mock(fetch: fetch) }
  let(:driver) { Persistence::Store::Drivers::Sequel::Postgres.new(db: db) }
  let(:mocker) { described_class.new(:users, driver: driver) }

  describe '#perform_custom' do
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
          mocker.perform_custom("SELECT * FROM users WHERE id = lola", {})
        end .to raise_error(Persistence::Errors::DriverError)
      end
    end
  end
end
