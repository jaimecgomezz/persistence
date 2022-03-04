# frozen_string_literal: true

RSpec.describe Persistence::Store::Operations::Capabilities::Requirer do
  let(:mocker) { Class.new { include Persistence::Store::Operations::Capabilities::Requirer }.new }

  describe '#requiring' do
    let(:operation_a) { Persistence::Store::Operations::Select.new(:a) }
    let(:operation_b) { Persistence::Store::Operations::Operation.new(:b) }

    it 'returns self' do
      expect(mocker.requiring(a: operation_a)).to be(mocker)
    end

    context 'with method being called multiple times' do
      let(:resulting) { mocker.requiring(a: operation_a) }

      it 'overwrites previous configuration' do
        expect(resulting.requiring(b: operation_b).requirements).to match({
          b: operation_b
        })
      end
    end

    context 'with positional arguments' do
      context 'having Operations as values' do
        let(:resulting) { mocker.requiring(a: operation_a, b: operation_b) }

        it 'assumes a list of operations with their alias were provided' do
          expect(resulting.requirements).to match({
            a: operation_a,
            b: operation_b
          })
        end
      end

      context 'having strings as values' do
        let(:directive_a) { "SELECT * FROM a" }
        let(:directive_b) { "SELECT * FROM b" }
        let(:resulting) { mocker.requiring(a: directive_a, b: directive_b) }

        it 'assumes that custom Directives with their alias were provided' do
          expect(resulting.requirements).to match({
            a: directive_a,
            b: directive_b
          })
        end
      end

      context 'having any other data type as values' do
        it 'raises exception' do
          expect { mocker.requiring(a: 1) }.to raise_error(Persistence::Errors::OperationError)
        end
      end
    end
  end
end
