# frozen_string_literal: true

RSpec.describe Persistence::Store::Drivers::Sequel::Postgres do
  let(:db) { Sequel.mock(fetch: fetch) }
  let(:mocker) { described_class.new(db: db, logging: false) }

  describe '#run_custom' do
    let(:id) { uuid }

    context 'with successful execution' do
      let(:fetch) { { id: id } }
      let(:result) { mocker.run_custom("SELECT * WHERE id = :id", { id: id }) }

      it 'runs custom statement' do
        expect(result.first).to match({ id: id })
      end
    end

    context 'with exception during execution' do
      let(:db) { Sequel.mock(fetch: StandardError) }

      it 'handles exception' do
        expect do
          mocker.run_custom("SELECT * WHERE id = :id", { id: id })
        end .to raise_error(Persistence::Errors::DriverError)
      end
    end
  end
end
