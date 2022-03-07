# frozen_string_literal: true

RSpec.describe Persistence::Store::Drivers::Sequel::Clauses::Returning do
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
    context 'with empty retrievables' do
      let(:result) { described_class.new(operation.retrieve({})).build }

      it 'returns empty string' do
        expect(result).to eq("")
      end
    end

    context 'with non-empty retrievables' do
      let(:result) { described_class.new(operation.retrieve(retrievables)).build }
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
            aggregation: :sum,
            cast: :uuid
          },
          d: {
            resource: 'td',
            alias: :D,
            aggregation: 'MAX',
            cast: 'uuids'
          },
          e: {
            resource: nil,
            alias: nil,
            aggregation: 'MIN',
            cast: 'CUSTOM'
          }
        }
      end

      it 'build clause' do
        sa = "ta.a AS A"
        sb = "tb.b AS B"
        sc = "SUM(tc.c::UUID) AS C"
        sd = "MAX(td.d::UUID[]) AS D"
        se = "MIN(a.e::CUSTOM)"
        joiner = ", "

        statement = ["RETURNING ", sa, joiner, sb, joiner, sc, joiner, sd, joiner, se].join

        expect(result).to eq(statement)
      end

      context 'with #distincs' do
        let(:result) { described_class.new(operation.retrieve(retrievables).distinct(:id, :email)).build }

        it 'builds clause including distinctiveness' do
          sa = "ta.a AS A"
          sb = "tb.b AS B"
          sc = "SUM(tc.c::UUID) AS C"
          sd = "MAX(td.d::UUID[]) AS D"
          se = "MIN(a.e::CUSTOM)"
          distinctiveness = "DISTINCT id, email "
          joiner = ", "

          statement = ["RETURNING ", distinctiveness, sa, joiner, sb, joiner, sc, joiner, sd, joiner, se].join

          expect(result).to eq(statement)
        end
      end
    end
  end
end
