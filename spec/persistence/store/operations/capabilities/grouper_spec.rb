# frozen_string_literal: true

RSpec.describe Persistence::Store::Operations::Capabilities::Grouper do
  let(:mocker) { Class.new { include Persistence::Store::Operations::Capabilities::Grouper }.new }

  describe '#group' do
    it 'returns self' do
      expect(mocker.group(:a)).to be(mocker)
    end

    context 'when method is called more than once' do
      let(:criteria) { [:a, :b, :c] }
      let(:resulting) { mocker.group(*criteria) }

      it 'respects newest grouping criteria' do
        second_criteria = [:x, *criteria, :y].shuffle
        expected = second_criteria.map { |c| { criteria: c } }

        expect(resulting.group(*second_criteria).groupings).to match(expected)
      end
    end

    context 'with positional arguments' do
      context 'being symbols/strings' do
        let(:resulting) { mocker.group(:a, :b) }

        it 'assumes a list of grouping criteria was provided' do
          expect(resulting.groupings).to match([
            { criteria: :a },
            { criteria: :b }
          ])
        end
      end

      context 'not being symbols/strings' do
        it 'raises exception' do
          expect { mocker.group(1) }.to raise_error(Persistence::Errors::OperationError)
        end
      end
    end

    context 'with keyword arguments' do
      context 'having hashes as values' do
        let(:resulting) { mocker.group(a: { apply: :sum }, b: { apply: :min }) }

        it 'assumes a list of criteria with custom mappings was provided' do
          expect(resulting.groupings).to match([
            { criteria: :a, apply: :sum },
            { criteria: :b, apply: :min }
          ])
        end
      end

      context 'having any other data type as values' do
        it 'raises exception' do
          expect { mocker.group(a: 1) }.to raise_error(Persistence::Errors::OperationError)
        end
      end
    end
  end
end
