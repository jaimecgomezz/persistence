# frozen_string_literal: true

RSpec.describe Persistence::Store::Operations::Capabilities::Retriever do
  let(:mocker) do
    Class.new do
      include Persistence::Store::Operations::Capabilities::Sourcer
      include Persistence::Store::Operations::Capabilities::Retriever
    end.new
  end

  describe '#retrieve' do
    it 'returns self' do
      expect(mocker.from(:a).retrieve(:id)).to be(mocker)
    end

    context 'with method being called more than once' do
      let(:resulting) { mocker.from(:a).retrieve(:id, name: :NAME) }

      it 'overwrites previous configuration' do
        expect(resulting.retrieve(:email, country: :CO, income: { alias: :IN, resource: :b }).retrievables).to match({
          email: {
            alias: nil,
            resource: :a
          },
          country: {
            alias: :CO,
            resource: :a
          },
          income: {
            alias: :IN,
            resource: :b
          }
        })
      end
    end

    context 'with positional arguments' do
      context 'being symbols/strings' do
        let(:resulting) { mocker.from(:a).retrieve(:id, :name) }

        it 'assumes list of fields was provided' do
          expect(resulting.retrievables).to match({
            id: {
              alias: nil,
              resource: :a
            },
            name: {
              alias: nil,
              resource: :a
            }
          })
        end
      end

      context 'not being symbols/strings' do
        it 'raises exception' do
          expect { mocker.retrieve(1) }.to raise_error(Persistence::Errors::OperationError)
        end
      end
    end

    context 'with keyword arguments' do
      context 'having symbols/strings as values' do
        let(:resulting) { mocker.from(:a).retrieve(id: :ID, name: :NAME) }

        it "assumes symbols are fields aliases" do
          expect(resulting.retrievables).to match({
            id: {
              alias: :ID,
              resource: :a
            },
            name: {
              alias: :NAME,
              resource: :a
            }
          })
        end
      end

      context 'having hashes as values' do
        let(:resulting) do
          mocker.from(:a).retrieve(id: { alias: :ID, resource: :users }, name: { alias: :NAME, resource: :users })
        end

        it 'assumes custom field mappings were given' do
          expect(resulting.retrievables).to match({
            id: {
              alias: :ID,
              resource: :users
            },
            name: {
              alias: :NAME,
              resource: :users
            }
          })
        end
      end

      context 'with any other data type as value' do
        it 'raises exception' do
          expect do
            mocker.from(:a).retrieve(id: 1, resource: :users)
          end .to raise_error(Persistence::Errors::OperationError)
        end
      end
    end
  end
end
