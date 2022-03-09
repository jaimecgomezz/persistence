# frozen_string_literal: true

require_relative 'context'

RSpec.describe Persistence::Store::Operations::Insert do
  let(:mocker) { described_class.new(:a) }

  include_context 'retriever'
  include_context 'requirer'
  include_context 'setter'
  include_context 'reactioner'

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
