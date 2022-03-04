# frozen_string_literal: true

RSpec.describe Persistence::Store::Operations::Capabilities::Sourcer do
  let(:mocker) do
    Class.new do
      include Persistence::Store::Operations::Capabilities::Sourcer

      attr_reader :source

      def initialize
        @source = :a
      end
    end.new
  end

  describe '#from' do
    it 'returns self' do
      expect(mocker.from(:b)).to be(mocker)
    end

    context 'with source being a symbol/string' do
      it 'overwrites current source' do
        expect(mocker.from(:b).source).to be(:b)
      end
    end

    context 'with source not being a symbol/string' do
      it 'raises exception' do
        expect { mocker.from(1) }.to raise_error(Persistence::Errors::OperationError)
      end
    end
  end
end
