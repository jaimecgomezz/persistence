# frozen_string_literal: true

RSpec.describe Persistence::Store::Operations::Capabilities::Reactioner do
  let(:mocker) { Class.new { include Persistence::Store::Operations::Capabilities::Reactioner }.new }

  describe '#react' do
    it 'returns self' do
      expect(mocker.react(conflicting: :a, action: :nothing)).to be(mocker)
    end

    context 'when it is called multiple times' do
      let(:resulting) { mocker.react(conflicting: :a, action: :nothing) }

      it 'overwrites previous configuration' do
        expect(resulting.react(conflicting: :b, action: :update).reaction).to match({
          conflicting: :b,
          action: :update,
          using: {}
        })
      end
    end

    context ':conflicting' do
      let(:resulting) { mocker.react(conflicting: conflicting, action: :nothing) }

      context 'being a symbol/string' do
        let(:conflicting) { :a }

        it 'assumes a constraint was provided' do
          expect(resulting.reaction).to include({ conflicting: conflicting })
        end
      end

      context 'being a list' do
        let(:conflicting) { [:a, :b] }

        it 'assumes a list of conflictive fields was provided' do
          expect(resulting.reaction).to include({ conflicting: conflicting })
        end
      end

      context 'being any other data type' do
        it 'raises exception' do
          expect { mocker.react(conflicting: 1, action: :nothing) }.to raise_error(Persistence::Errors::OperationError)
        end
      end
    end

    context ':action' do
      let(:resulting) { mocker.react(conflicting: :a, action: :update) }

      context 'being a symbol/string' do
        it 'assumes a valid action was provided' do
          expect(resulting.reaction).to include({ action: :update })
        end
      end

      context 'being any other data type' do
        it 'raises exception' do
          expect { mocker.react(conflicting: :a, action: 1) }.to raise_error(Persistence::Errors::OperationError)
        end
      end
    end
  end
end
