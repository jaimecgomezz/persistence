# frozen_string_literal: true

RSpec.describe Persistence::Store::Operations::Capabilities::Setter do
  let(:mocker) { Class.new { include Persistence::Store::Operations::Capabilities::Setter }.new }

  describe '#set' do
    it 'returns self' do
      expect(mocker.set({ a: :default })).to be(mocker)
    end

    context 'when called multiple times' do
      let(:resulting) { mocker.set({ a: :default }) }

      it 'overwrites previous configuration' do
        expect(resulting.set({ b: :default }).assignments).to match([
          {
            field: :b,
            value: :default,
            kind: :expression
          }
        ])
      end
    end

    context 'with valid custom mappings as values' do
      let(:resulting) { mocker.set({ a: { value: 1, kind: :literal }, b: { value: nil, kind: :literal } }) }

      it 'assumes a list of fields with custom mappings was provided' do
        expect(resulting.assignments).to match([
          {
            field: :a,
            value: 1,
            kind: :literal
          },
          {
            field: :b,
            value: nil,
            kind: :literal
          }
        ])
      end
    end

    context 'having any other data type as values' do
      let(:resulting) { mocker.set({ a: 1, b: { org: { id: 1 } } }) }

      it 'assumes a list of fields with their literal values was provided' do
        expect(resulting.assignments).to match([
          {
            field: :a,
            value: 1,
            kind: :literal
          },
          {
            field: :b,
            value: { org: { id: 1 } },
            kind: :literal
          }
        ])
      end
    end
  end
end
