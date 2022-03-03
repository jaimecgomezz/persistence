# frozen_string_literal: true

RSpec.describe Persistence::Store::Operations::Capabilities::Aggregator do
  let(:mocker) { Class.new { include Persistence::Store::Operations::Capabilities::Aggregator }.new }

  describe '#aggregate' do
    it 'returns self' do
      expect(mocker.aggregate(:income, aggregation: :sum)).to be(mocker)
    end

    context 'with positional arguments all being symbols' do
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

    context 'with positional arguments all being lists of symbols' do
      let(:resulting) { mocker.aggregate([:income, :INCOME], [:age, :AGE], aggregation: :sum) }

      it 'assumes list of fields with their alias was provided' do
        expect(resulting.aggregations).to match({
          income: {
            alias: :INCOME,
            aggregation: :sum
          },
          age: {
            alias: :AGE,
            aggregation: :sum
          }
        })
      end
    end

    context 'with positional arguments either symbols or lists of symbols' do
      let(:resulting) { mocker.aggregate(:income, [:age, :AGE], aggregation: :sum) }

      it 'assumes list of fields with optional aliases was provided' do
        expect(resulting.aggregations).to match({
          income: {
            alias: nil,
            aggregation: :sum
          },
          age: {
            alias: :AGE,
            aggregation: :sum
          }
        })
      end
    end
  end
end
