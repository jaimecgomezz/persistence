# frozen_string_literal: true

RSpec.describe Persistence::Store::Operations::Capabilities::Aggregator do
  let(:mocker) { Class.new { include Persistence::Store::Operations::Capabilities::Aggregator }.new }

  describe '#aggregate' do
    it 'returns self' do
      expect(mocker.aggregate(age: :sum)).to be(mocker)
    end

    context 'when called multiples times' do
      let(:resulting) { mocker.aggregate(age: :avg) }

      it 'overwrites previous configuration' do
        expect(resulting.aggregate(income: :sum).aggregations).to match({
          income: {
            alias: nil,
            aggregation: :sum
          }
        })
      end
    end

    context 'with keyword arguments' do
      context 'having symbols/strings as their values' do
        let(:resulting) { mocker.aggregate(age: :avg, income: :sum) }

        it "assumes a list of fields with their aggregations was provided" do
          expect(resulting.aggregations).to match({
            age: {
              alias: nil,
              aggregation: :avg
            },
            income: {
              alias: nil,
              aggregation: :sum
            }
          })
        end
      end

      context 'having hashes as their values' do
        context 'and hashes being valid custom mappings' do
          let(:resulting) do
            mocker.aggregate(age: { alias: :AGE, aggregation: :avg }, income: { alias: :INCOME, aggregation: :sum })
          end

          it 'assumes custom field mapping was provided' do
            expect(resulting.aggregations).to match({
              age: {
                alias: :AGE,
                aggregation: :avg
              },
              income: {
                alias: :INCOME,
                aggregation: :sum
              }
            })
          end
        end

        context 'and hashes being invalid custom aggregation mappings' do
          it 'raises exception' do
            expect { mocker.aggregate(a: {}) }.to raise_error(Persistence::Errors::OperationError)
          end
        end
      end

      context 'having any other data type as their values' do
        it 'raises exception' do
          expect { mocker.aggregate(a: 1, aggregation: :sum) }.to raise_error(Persistence::Errors::OperationError)
        end
      end
    end
  end
end
