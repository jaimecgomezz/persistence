# frozen_string_literal: true

RSpec.describe Persistence::Store::Drivers::Sequel::Clauses::Select do
  let(:base) { Persistence::Store::Operations::Select.new(:a) }
  let(:mocker) { described_class.new(operation, {}) }

  describe '.new' do
    it 'expects operation and params' do
      expect(described_class).to respond_to(:new).with(2).argument
    end
  end

  describe '#build' do
    let(:result) { mocker.build }

    context 'with empty #retrievables' do
      let(:operation) { base }

      it 'returns empty statement' do
        expect(result).to eq(["", {}])
      end
    end

    context 'with non-empty #retrievables' do
      let(:retriever) do
        base.retrieve(
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
        )
      end
      let(:operation) { retriever }

      it 'build clause' do
        params = {}
        statement = [
          "SELECT", [
            "ta.a AS A",
            "tb.b AS B",
            "SUM(tc.c::UUID) AS C",
            "MAX(td.d::UUID[]) AS D",
            "MIN(a.e::CUSTOM)"
          ].join(", ")
        ].join(" ")

        expect(result).to match([statement, params])
      end

      context 'with #distincs' do
        let(:operation) { retriever.distinct(:id, :email) }

        it 'builds clause including distinctiveness' do
          params = {}
          statement = [
            "SELECT",
            "DISTINCT id, email",
            [
              "ta.a AS A",
              "tb.b AS B",
              "SUM(tc.c::UUID) AS C",
              "MAX(td.d::UUID[]) AS D",
              "MIN(a.e::CUSTOM)"
            ].join(", ")
          ].join(" ")

          expect(result).to match([statement, params])
        end
      end
    end

    context 'with Operation not being a Retriever' do
      let(:operation) { Persistence::Store::Operations::Operation.new(:a) }

      it 'raises exception' do
        expect { mocker.build }.to raise_error(Persistence::Errors::DriverError)
      end
    end

    context 'with Operation not being a Differentiator' do
      let(:operation) { Persistence::Store::Operations::Operation.new(:a) }

      it 'raises exception' do
        expect { mocker.build }.to raise_error(Persistence::Errors::DriverError)
      end
    end
  end
end
