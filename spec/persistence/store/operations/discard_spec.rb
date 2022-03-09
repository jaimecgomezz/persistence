# frozen_string_literal: true

require_relative 'context'

RSpec.describe Persistence::Store::Operations::Discard do
  let(:mocker) { described_class.new(:a) }

  include_context 'filter'
  include_context 'retriever'
  include_context 'setter'

  it 'sets discardable attribute by default' do
    keys = mocker.assignments.map { |a| a[:__field] }

    expect(keys).to include(Persistence::Config::DISCARD_ATTRIBUTE)
  end

  describe '#after' do
    let(:result) { mocker.after(results) }

    context 'with results size being 1' do
      let(:results) { [1] }

      it 'returns first item' do
        expect(result).to match(results.first)
      end
    end

    context 'with results size being different than 1' do
      let(:results) { [1, 2, 3] }

      it 'returns all items' do
        expect(result).to match(results)
      end
    end
  end
end
