# frozen_string_literal: true

RSpec.describe Persistence::Store::Operations::Capabilities::Differentiator do
  let(:mocker) { Class.new { include Persistence::Store::Operations::Capabilities::Differentiator }.new }

  describe '#distinct' do
    it 'returns self' do
      expect(mocker.distinct(:a)).to be(mocker)
    end

    context 'with method being called multiple times' do
      let(:resulting) { mocker.distinct(:a, b: { alias: :B }) }

      it 'overwrites previous configuration' do
        expect(resulting.distinct(:c, d: { alias: :D }).distincts).to match([
          { criteria: :c },
          { criteria: :d, alias: :D }
        ])
      end
    end

    context 'with positional arguments' do
      context 'being symbols/strings' do
        let(:resulting) { mocker.distinct(:a, :b) }

        it 'assumes a list of distinctiveness criteria was provided' do
          expect(resulting.distincts).to match([
            { criteria: :a },
            { criteria: :b }
          ])
        end
      end

      context 'not being symbols/strings' do
        it 'raises exception' do
          expect { mocker.distinct(1) }.to raise_error(Persistence::Errors::OperationError)
        end
      end
    end

    context 'with keyword arguments' do
      context 'having hashes as values' do
        let(:resulting) { mocker.distinct(:a, b: { apply: :sum }, c: { alias: :C }) }

        it 'assumes a list of ordering criteria with custom mappings was provided' do
          expect(resulting.distincts).to match([
            { criteria: :a },
            { criteria: :b, apply: :sum },
            { criteria: :c, alias: :C }
          ])
        end
      end
    end
  end
end
