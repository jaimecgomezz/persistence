# frozen_string_literal: true

RSpec.describe Persistence::Store::Operations::Capabilities::DiscardedManager do
  let(:mocker) { Class.new { include Persistence::Store::Operations::Capabilities::DiscardedManager }.new }

  describe '#include_discarded' do
    let(:resulting) { mocker.include_discarded }

    it 'returns self' do
      expect(mocker.include_discarded).to be(mocker)
    end

    it 'removes filters that exclude discarded attributes' do
      expect(resulting.global_filters.keys).not_to include(Persistence::Config::DISCARD_ATTRIBUTE)
    end
  end

  describe '#exclude_discarded' do
    let(:resulting) { mocker.exclude_discarded }

    it 'returns self' do
      expect(mocker.include_discarded).to be(mocker)
    end

    it 'adds filters that exclude discarded attributes' do
      expect(resulting.global_filters.keys).to include(Persistence::Config::DISCARD_ATTRIBUTE)
    end
  end
end
