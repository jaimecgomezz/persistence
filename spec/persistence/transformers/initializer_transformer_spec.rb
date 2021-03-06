# frozen_string_literal: true

require_relative 'context'

RSpec.describe Persistence::Transformers::InitializerTransformer do
  let(:entity) do
    Class.new do
      attr_reader :id

      def initialize(attrs)
        @id = attrs[:id]
      end

      def to_h
        { id: id }
      end
    end
  end

  let(:instance) { described_class.new(entity) }

  include_context 'transformer'

  describe '.new' do
    it 'expects entity' do
      expect(described_class).to respond_to(:new).with(1).argument
    end
  end

  describe '#one' do
    let(:one) { { id: uuid } }

    context 'with hash as argument' do
      let(:transformed) { instance.one(one) }

      it 'transforms argument' do
        expect(transformed).to be_a(entity)
      end

      it "delegates setting element's attributes to entity" do
        expect(transformed.to_h).to match(one)
      end
    end

    context 'with nil as argument' do
      it 'returns nil' do
        expect(instance.one(nil)).to be_nil
      end
    end

    context 'with entity not handling .new(attributes)' do
      let(:entity) { Class.new }
      let(:instance) { described_class.new(entity) }

      it 'raises exception' do
        expect { instance.one(one) }.to raise_error(Persistence::Errors::TransformerError) 
      end
    end
  end

  describe '#many' do
    let(:many) { [{ id: uuid }] }
    let(:transformed) { instance.many(many) }

    it 'transforms elements' do
      expect(transformed).to all(be_a(entity))
    end

    it "delegates setting elements' attributes to entity" do
      expect(transformed.map(&:to_h)).to match(many)
    end
  end
end
