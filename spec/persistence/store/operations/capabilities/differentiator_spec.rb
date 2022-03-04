# frozen_string_literal: true

RSpec.describe Persistence::Store::Operations::Capabilities::Differentiator do
  let(:mocker) { Class.new { include Persistence::Store::Operations::Capabilities::Differentiator }.new }

  describe '#distinct' do
    it 'returns self' do
      expect(mocker.distinct(:a)).to be(mocker)
    end

    context 'with method being called multiple times' do
      let(:resulting) { mocker.distinct(:a) }

      it 'overwrites distinctiveness configuration' do
        expect(resulting.distinct(:b, on: :b).distincts).to match({ on: :b, distincts: [:b] })
      end
    end

    context 'with positional arguments' do
      context 'being symbols/strings' do
        let(:resulting) { mocker.distinct(:a, :b, :c) }

        it 'assumes a list of distinctiveness criteria was given' do
          expect(resulting.distincts).to match({ on: nil, distincts: [:a, :b, :c] })
        end

        context 'with :on being provided' do
          let(:resulting) { mocker.distinct(:a, :b, :c, on: :a) }

          it 'is included in the distinctiveness mapping' do
            expect(resulting.distincts).to match({ on: :a, distincts: [:a, :b, :c] })
          end
        end
      end
    end
  end
end
