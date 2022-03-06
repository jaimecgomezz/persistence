# frozen_string_literal: true

RSpec.describe Persistence::Store::Drivers::Sequel::Clauses::With do
  let(:operation) { Persistence::Store::Operations::Select.new(:a) }

  context '.new' do
    it 'expects operation' do
      expect(described_class).to respond_to(:new).with(1).argument
    end

    context 'with Operation being a Requirer' do
      it 'initializes class' do
        expect(described_class.new(operation)).to be_a(described_class)
      end
    end

    context 'with Operation not being a Requirer' do
      let(:operation) { Persistence::Store::Operations::Operation.new(:a) }

      it 'raises exception' do
        expect { described_class.new(operation) }.to raise_error(Persistence::Errors::DriverError)
      end
    end
  end

  context '#build' do
    let(:result) { described_class.new(operation.requiring(requirements)).build }

    context 'with empty requirements' do
      let(:requirements) { {} }

      it 'returns empty string' do
        expect(result).to eq("")
      end
    end

    context 'with non-empty requirements' do
      let(:requirements) { { a: "SELECT * FROM a", b: "SELECT id FROM b", c: "SELECT COUNT(*) FROM c" } }

      it 'build clause' do
        sa = "a AS (#{requirements[:a]})"
        sb = "b AS (#{requirements[:b]})"
        sc = "c AS (#{requirements[:c]})"
        joiner = ", "

        statement = ["WITH ", sa, joiner, sb, joiner, sc].join

        expect(result).to eq(statement)
      end
    end
  end
end
