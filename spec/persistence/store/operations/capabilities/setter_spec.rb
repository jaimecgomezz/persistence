# frozen_string_literal: true

RSpec.describe Persistence::Store::Operations::Capabilities::Setter do
  let(:mocker) { Class.new { include Persistence::Store::Operations::Capabilities::Setter }.new }

  describe '#set' do
    it 'returns self' do
      expect(mocker.set(:a)).to be(mocker)
    end

    context 'when called multiple times' do
      let(:resulting) { mocker.set(:a) }

      it 'overwrites previous configuration' do
        expect(resulting.set(:b).assignments).to match({
          b: {
            __value: :default,
            __kind: :expression
          }
        })
      end
    end

    context 'with positional arguments' do
      context 'being symbols/string' do
        let(:resulting) { mocker.set(:a, :b) }

        it 'assumes a list of fields with default values was provided' do
          expect(resulting.assignments).to match({
            a: {
              __value: :default,
              __kind: :expression
            },
            b: {
              __value: :default,
              __kind: :expression
            }
          })
        end
      end

      context 'not being symbols, :strings' do
        it 'raises exception' do
          expect { mocker.set(1) }.to raise_error(Persistence::Errors::OperationError)
        end
      end
    end

    context 'with keyword arguments' do
      context 'having valid field mappings as values' do
        let(:resulting) { mocker.set(a: { __value: 1, __kind: :literal }, b: { __value: nil, __kind: :literal }) }

        it 'assumes a list of fields with custom mappings was provided' do
          expect(resulting.assignments).to match({
            a: {
              __value: 1,
              __kind: :literal
            },
            b: {
              __value: nil,
              __kind: :literal
            }
          })
        end
      end

      context 'having any other data type as values' do
        let(:resulting) { mocker.set(a: 1, b: { org: { id: 1 } }) }

        it 'assumes a list of fields with their literal values was provided' do
          expect(resulting.assignments).to match({
            a: {
              __value: 1,
              __kind: :literal
            },
            b: {
              __value: { org: { id: 1 } },
              __kind: :literal
            }
          })
        end
      end
    end
  end
end
