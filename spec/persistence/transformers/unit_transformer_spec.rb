# frozen_string_literal: true

require_relative 'context'

RSpec.describe Persistence::Transformers::UnitTransformer do
  let(:instance) { described_class.new }

  include_context 'transformer'

  describe '.new' do
    it 'expects no arguments' do
      expect(described_class).to respond_to(:new)
    end
  end

  describe '#one' do
    let(:one) { [1, 'a', {}, [], Class.new].sample }

    it 'returns argument' do
      expect(instance.one(one)).to be(one)
    end
  end

  describe '#many' do
    let(:many) { [1, 2, 3, 4, 5, 6, 7, 8, 9] }

    it 'returns argument' do
      expect(instance.many(many)).to be(many)
    end
  end
end
