# frozen_string_literal: true

RSpec.describe Persistence::Store::Drivers::Sequel::Clauses::Order do
  let(:base) { Persistence::Store::Operations::Select.new(:a) }
  let(:mocker) { described_class.new(operation, {}) }

  context '.new' do
    it 'expects operation and params' do
      expect(described_class).to respond_to(:new).with(2).argument
    end
  end

  context '#build' do
    let(:operation) { base }
    let(:result) { mocker.build }

    context 'with non-defined orderings' do
      it 'returns empty statement' do
        expect(result).to eq(["", {}])
      end
    end

    context 'with defined orderings' do
      let(:operation) do
        base.order(
          :created_at,
          updated_at: :desc,
          deleted_at: { order: 'ASC', nulls: :last },
          removed_at: { order: 'CUSTOM', nulls: 'CUSTOM' }
        )
      end

      it 'build clause' do
        sa = "created_at ASC NULLS LAST"
        sb = "updated_at DESC NULLS LAST"
        sc = "deleted_at ASC NULLS LAST"
        sd = "removed_at CUSTOM NULLS CUSTOM"
        joiner = ", "

        statement = ["ORDER BY ", sa, joiner, sb, joiner, sc, joiner, sd].join

        expect(result).to eq([statement, {}])
      end
    end

    context 'with Operation not being a Orderer' do
      let(:operation) { Persistence::Store::Operations::Operation.new(:a) }

      it 'raises exception' do
        expect { mocker.build }.to raise_error(Persistence::Errors::DriverError)
      end
    end
  end
end
