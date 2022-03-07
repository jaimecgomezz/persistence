# frozen_string_literal: true

RSpec.describe Persistence::Store::Drivers::Sequel::Clauses::Order do
  let(:operation) { Persistence::Store::Operations::Select.new(:a) }

  context '.new' do
    it 'expects operation' do
      expect(described_class).to respond_to(:new).with(1).argument
    end

    context 'with Operation being a Orderer' do
      it 'initializes class' do
        expect(described_class.new(operation)).to be_a(described_class)
      end
    end

    context 'with Operation not being a Orderer' do
      let(:operation) { Persistence::Store::Operations::Operation.new(:a) }

      it 'raises exception' do
        expect { described_class.new(operation) }.to raise_error(Persistence::Errors::DriverError)
      end
    end
  end

  context '#build' do
    context 'with empty orderings' do
      let(:result) { described_class.new(operation.order({})).build }

      it 'returns empty string' do
        expect(result).to eq("")
      end
    end

    context 'with non-empty orderings' do
      let(:result) do
        described_class.new(operation.order(
          :created_at,
          updated_at: :desc,
          deleted_at: { order: 'ASC', nulls: :last },
          removed_at: { order: 'CUSTOM', nulls: 'CUSTOM' }
        )).build
      end

      it 'build clause' do
        sa = "created_at ASC NULLS LAST"
        sb = "updated_at DESC NULLS LAST"
        sc = "deleted_at ASC NULLS LAST"
        sd = "removed_at CUSTOM NULLS CUSTOM"
        joiner = ", "

        statement = ["ORDER BY ", sa, joiner, sb, joiner, sc, joiner, sd].join

        expect(result).to eq(statement)
      end
    end
  end
end
