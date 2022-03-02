# frozen_string_literal: true

RSpec.describe Persistence::Store::Operations::Capabilities::Aggregator do
  let(:mocker) { Class.new { include Persistence::Store::Operations::Capabilities::Aggregator }.new }

  let(:function) { [:max, :min, :sum, :count].sample }

  describe '#aggregate' do
    let(:overwriter_function) { [:any, :other, :value, :lol].sample }

    context 'with a symbol as argument' do
      let(:symbol) { :a }
      let(:resulting) { mocker.aggregate(function, symbol) }

      it 'build aggregation for field with no alias' do
        expected = Hash[[[symbol, { function: function, alias: nil }]]]

        expect(resulting.send(:aggregations)).to match(expected)
      end

      context 'with previously defined aggregation' do
        let(:second_resulting) { resulting.aggregate(overwriter_function, symbol) }

        it 'overwrites field aggregation' do
          expected = Hash[[[symbol, { function: overwriter_function, alias: nil }]]]

          expect(second_resulting.send(:aggregations)).to match(expected)
        end
      end
    end

    context 'with a list of symbols as argument' do
      let(:resulting) { mocker.aggregate(function, list) }

      context 'with size of 0' do
        let(:list) { [] }

        it 'raises exception' do
          expect { mocker.aggregate(function, list) }.to raise_error(Persistence::Errors::OperationError)
        end
      end

      context 'with size of 1 or 2' do
        let(:list) { [[:a], [:a, :A]].sample }

        it 'builds aggregation for field with alias' do
          expected = Hash[[[list[0], { function: function, alias: list[1] }]]]

          expect(resulting.send(:aggregations)).to match(expected)
        end

        context 'with previously defined aggregation' do
          let(:second_resulting) { resulting.aggregate(overwriter_function, list) }

          it 'overwrites field aggregation' do
            expected = Hash[[[list[0], { function: overwriter_function, alias: list[1] }]]]

            expect(second_resulting.send(:aggregations)).to match(expected)
          end
        end
      end

      context 'with size over 2' do
        let(:list) { [:a, :A, :B] }

        it 'builds aggregation for field and ignores argument surplus' do
          expected = Hash[[[list[0], { function: function, alias: list[1] }]]]

          expect(resulting.send(:aggregations)).to match(expected)
        end
      end
    end

    context 'with a list of lists of symbols as argument' do
      let(:resulting) { mocker.aggregate(function, list) }

      context 'with any having size of 0' do
        let(:list) { [[]] }

        it 'raises exception' do
          expect { mocker.aggregate(function, list) }.to raise_error(Persistence::Errors::OperationError)
        end
      end

      context 'with each having size of 1 or 2' do
        let(:list) { [[[:a], [:a, :A]].sample] }

        it 'builds aggregation for field with alias' do
          expected = Hash[[[list[0][0], { function: function, alias: list[0][1] }]]]

          expect(resulting.send(:aggregations)).to match(expected)
        end

        context 'with previously defined aggregation' do
          let(:second_resulting) { resulting.aggregate(overwriter_function, list) }

          it 'overwrites field aggregation' do
            expected = Hash[[[list[0][0], { function: overwriter_function, alias: list[0][1] }]]]

            expect(second_resulting.send(:aggregations)).to match(expected)
          end
        end
      end

      context 'with any having size over 2' do
        let(:list) { [[:a, :A, :B]] }

        it 'builds aggregation for field and ignores argument surplus' do
          expected = Hash[[[list[0][0], { function: function, alias: list[0][1] }]]]

          expect(resulting.send(:aggregations)).to match(expected)
        end
      end
    end

    context 'with any other thing as argument' do
      let(:other) { [1, {}, Class.new, true].sample }

      it 'raises exception' do
        expect { mocker.aggregate(function, other) }.to raise_error(Persistence::Errors::OperationError)
      end
    end
  end
end
