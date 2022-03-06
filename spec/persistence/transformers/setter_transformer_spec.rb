# frozen_string_literal: true

require_relative 'context'

RSpec.describe Persistence::Transformers::SetterTransformer do
  let(:entity) do
    Class.new do
      attr_accessor :id

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

      it 'sets argument attributes' do
        expect(transformed.to_h).to match(one)
      end

      context 'and entity missing attributes setters' do
        it 'raises exception' do
          expect { instance.one(one.merge({ identity: uuid })) }.to raise_error(Persistence::Errors::TransformerError)
        end
      end
    end

    context 'with nil as argument' do
      it 'returns nil' do
        expect(instance.one(nil)).to be_nil
      end
    end
  end

  describe '#many' do
    let(:many) { [{ id: uuid }] }
    let(:transformed) { instance.many(many) }

    it 'transforms elements' do
      expect(transformed).to all(be_a(entity))
    end

    it "sets element's attributes" do
      expect(transformed.map(&:to_h)).to match(many)
    end
  end
end
