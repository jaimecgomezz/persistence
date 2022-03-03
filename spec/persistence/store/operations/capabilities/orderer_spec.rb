# frozen_string_literal: true

RSpec.describe Persistence::Store::Operations::Capabilities::Orderer do
  let(:mocker) { Class.new { include Persistence::Store::Operations::Capabilities::Orderer }.new }

  describe '#order' do
    context 'with postional argumets' do
      context 'being symbols/strings' do
        let(:resulting) { mocker.order(:created_at) }

        it 'assumes a list of ordering criteria with default ordering was given' do
          expect(resulting.orderings).to match({
            created_at: {
              order: :asc,
              nulls: nil
            }
          })
        end

        context 'with :nulls provided' do
          let(:resulting) { mocker.order(:created_at, nulls: :last) }

          it 'includes it in each criteria mapping' do
            expect(resulting.orderings).to match({
              created_at: {
                order: :asc,
                nulls: :last
              }
            })
          end
        end
      end

      context 'being any other data type' do
        it 'raises exception' do
          expect { mocker.order(1) }.to raise_error(Persistence::Errors::OperationError)
        end
      end
    end

    context 'with keyword arguments' do
      context 'having symbols/strings as values' do
        let(:resulting) { mocker.order(created_at: :desc) }

        it 'assumes a list of criteria with custom ordering was given' do
          expect(resulting.orderings).to match({
            created_at: {
              order: :desc,
              nulls: nil
            }
          })
        end

        context 'with :nulls provided' do
          let(:resulting) { mocker.order(created_at: :desc, nulls: :first) }

          it 'includes it in each criteria mapping' do
            expect(resulting.orderings).to match({
              created_at: {
                order: :desc,
                nulls: :first
              }
            })
          end
        end
      end

      context 'with hashes as values' do
        let(:created_at_mapping) { { order: :desc, nulls: :first } }
        let(:updated_at_mapping) { { order: :asc, nulls: :last } }
        let(:resulting) { mocker.order(created_at: created_at_mapping, updated_at: updated_at_mapping) }

        it 'assumes a list of criteria with custom mappings was given' do
          expect(resulting.orderings).to match({
            created_at: created_at_mapping,
            updated_at: updated_at_mapping
          })
        end

        context 'with :nulls provided' do
          let(:resulting) do
            mocker.order(created_at: created_at_mapping, updated_at: updated_at_mapping, nulls: :first)
          end

          it 'respects custom mappings' do
            expect(resulting.orderings).to match({
              created_at: created_at_mapping,
              updated_at: updated_at_mapping
            })
          end
        end
      end

      context 'with any other data type as values' do
        it 'raises exception' do
          expect { mocker.order(created_at: 1) }.to raise_error(Persistence::Errors::OperationError)
        end
      end
    end
  end
end
