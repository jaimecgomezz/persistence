# frozen_string_literal: true

RSpec.describe Persistence::Store::Operations::Capabilities::Aggregator do
  let(:mocker) { Class.new { include Persistence::Store::Operations::Capabilities::Aggregator }.new }

  describe '#aggregate' do
    it 'returns self' do
      expect(mocker.aggregate(:income, aggregation: :sum)).to be(mocker)
    end

    context 'with positional arguments' do
      context 'being symbols/strings' do
        let(:resulting) { mocker.aggregate(:income, :age, aggregation: :sum) }

        it 'assumes list of fields was provided' do
          expect(resulting.aggregations).to match({
            income: {
              alias: nil,
              aggregation: :sum
            },
            age: {
              alias: nil,
              aggregation: :sum
            }
          })
        end
      end

      context 'not being symbols/strings' do
        it 'raises exception' do
          expect { mocker.aggregate(1, aggregation: :sum) }.to raise_error(Persistence::Errors::OperationError)
        end
      end
    end

    context 'with keyword arguments' do
      context 'being symbols/strings' do
        let(:resulting) { mocker.aggregate(a: :A, aggregation: :sum) }

        it "assumes field's alias was provided" do
          expect(resulting.aggregations).to match({
            a: {
              alias: :A,
              aggregation: :sum
            }
          })
        end
      end

      context 'being hashes' do
        let(:mapping) { { alias: :A, aggregation: :max } }
        let(:resulting) { mocker.aggregate(a: mapping, aggregation: :sum) }

        it 'assumes custom field mapping was provided' do
          expect(resulting.aggregations).to match({ a: mapping })
        end
      end

      context 'being any other data type' do
        it 'raises exception' do
          expect { mocker.aggregate(a: 1, aggregation: :sum) }.to raise_error(Persistence::Errors::OperationError)
        end
      end
    end
  end
end
