# frozen_string_literal: true

RSpec.describe Persistence::Store::Operations::Operation do
  let(:instance) { described_class.new(:a) }

  describe '.new' do
    it 'expects source' do
      expect(described_class).to respond_to(:new).with(1).argument
    end
  end

  describe '#name' do
    let(:mocker) do
      class SomeRandomName < Persistence::Store::Operations::Operation
      end

      SomeRandomName.new(:a)
    end

    it 'properly formats name' do
      expect(mocker.name).to be(:some_random_name)
    end
  end

  describe '#after' do
    it 'simply returns result' do
      expect(instance.after(1)).to be(1)
    end
  end
end
