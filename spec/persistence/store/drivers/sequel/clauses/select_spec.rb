# frozen_string_literal: true

RSpec.describe Persistence::Store::Drivers::Sequel::Clauses::Select do
  let(:operation) { Persistence::Store::Operations::Select.new(:a) }

  describe '.new' do
    it 'expects operation' do
      expect(described_class).to respond_to(:new).with(1).argument
    end

    context 'with operation being a Retriver' do
      it 'initializes class' do
        expect(described_class.new(operation)).to be_a(described_class)
      end
    end

    context 'with Operation not being a Retriever' do
      let(:operation) { Persistence::Store::Operations::Operation.new(:a) }

      it 'raises exception' do
        expect { described_class.new(operation) }.to raise_error(Persistence::Errors::DriverError)
      end
    end
  end

  describe '#build' do
    let(:result) { described_class.new(operation.retrieve(retrievables)).build }

    context 'with empty #retrievables' do
      let(:retrievables) { {} }

      it 'returns empty string' do
        expect(result).to eq("")
      end
    end

    context 'with non-empty #retrievables' do
      let(:retrievables) do
        {
          a: {
            resource: :ta,
            alias: :A
          },
          b: {
            resource: 'tb',
            alias: 'B'
          },
          c: {
            resource: :tc,
            alias: 'C',
            aggregation: :sum
          },
          d: {
            resource: 'td',
            alias: :D,
            aggregation: 'MAX'
          },
          e: {
            resource: nil,
            alias: nil,
            aggregation: 'MIN'
          }
        }
      end

      it 'build clause' do
        sa = "ta.a AS A"
        sb = "tb.b AS B"
        sc = "SUM(tc.c) AS C"
        sd = "MAX(td.d) AS D"
        se = "MIN(e)"
        joiner = ", "

        statement = ["SELECT ", sa, joiner, sb, joiner, sc, joiner, sd, joiner, se].join

        expect(result).to eq(statement)
      end
    end
  end
end
