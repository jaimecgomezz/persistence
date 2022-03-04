# frozen_string_literal: true

RSpec.describe Persistence::Store::Operations::Capabilities::Joiner do
  let(:mocker) do
    Class.new do
      include Persistence::Store::Operations::Capabilities::Sourcer
      include Persistence::Store::Operations::Capabilities::Joiner
    end.new
  end

  describe 'join' do
    it 'returns self' do
      expect(mocker.from(:a).join(b: { kind: :lo, right: :id, left: :a_id })).to be(mocker)
    end

    context 'with method being called multiple times' do
      let(:resulting) { mocker.from(:a).join(b: { kind: :fro, left: :id, right: :a_id }) }

      it 'overwrites previous configuration' do
        expect(resulting.join(c: { kind: :flo, left: :id, right: :a_id }).joins).to match({
          c: {
            kind: :flo,
            left: :id,
            right: :a_id
          }
        })
      end
    end

    context 'with keyword arguments' do
      context 'having valid mappings as values' do
        let(:resulting) { mocker.from(:a).join(b: { kind: :fro, left: :id, right: :a_id }) }

        it 'assumes a list of resources with joining configuration was provided' do
          expect(resulting.joins).to match({
            b: {
              kind: :fro,
              left: :id,
              right: :a_id
            }
          })
        end
      end

      context 'having invalid mappings as values' do
        it 'raises exception' do
          expect { mocker.join(b: {}) }.to raise_error(Persistence::Errors::OperationError)
        end
      end

      context 'having any other data type as values' do
        it 'raises exception' do
          expect { mocker.join(b: 1) }.to raise_error(Persistence::Errors::OperationError)
        end
      end
    end
  end
end
