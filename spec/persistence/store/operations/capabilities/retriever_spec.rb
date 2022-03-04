# frozen_string_literal: true

RSpec.describe Persistence::Store::Operations::Capabilities::Retriever do
  let(:mocker) { Class.new { include Persistence::Store::Operations::Capabilities::Retriever }.new }

  describe '#retrieve' do
    it 'returns self' do
      expect(mocker.retrieve(:id)).to be(mocker)
    end

    context 'with method being called more than once' do
      let(:resulting) { mocker.retrieve(:id, name: :NAME, resource: :users) }

      it 'overwrites previous configuration' do
        expect(resulting.retrieve(
          :email,
            country: :CO,
            income: {
              alias: :IN,
              resource: :any
            },
            resource: :other
        ).retrievables).to match({
          email: {
            alias: nil,
            resource: :other
          },
          country: {
            alias: :CO,
            resource: :other
          },
          income: {
            alias: :IN,
            resource: :any
          }
        })
      end
    end

    context 'with positional arguments' do
      context 'being symbols/strings' do
        let(:resulting) { mocker.retrieve(:id, :name) }

        it 'assumes list of fields was provided' do
          expect(resulting.retrievables).to match({
            id: {
              alias: nil,
              resource: nil
            },
            name: {
              alias: nil,
              resource: nil
            }
          })
        end

        context 'with :resource provided' do
          let(:resulting) { mocker.retrieve(:id, :name, resource: :users) }

          it 'includes resource in mapping' do
            expect(resulting.retrievables).to match({
              id: {
                alias: nil,
                resource: :users
              },
              name: {
                alias: nil,
                resource: :users
              }
            })
          end
        end
      end

      context 'not being symbols/strings' do
        it 'raises exception' do
          expect { mocker.retrieve(1, resource: :users) }.to raise_error(Persistence::Errors::OperationError)
        end
      end
    end

    context 'with keyword arguments' do
      context 'having symbols/strings as values' do
        let(:resulting) { mocker.retrieve(id: :ID, name: :NAME, resource: :other) }

        it "assumes symbols are fields aliases" do
          expect(resulting.retrievables).to match({
            id: {
              alias: :ID,
              resource: :other
            },
            name: {
              alias: :NAME,
              resource: :other
            }
          })
        end
      end

      context 'having hashes as values' do
        let(:id_hash) { { alias: :ID, resource: :users } }
        let(:name_hash) { { alias: :NAME, resource: :users } }

        let(:resulting) { mocker.retrieve(id: id_hash, name: name_hash, resource: :other) }

        it 'assumes custom field mappings were given' do
          expect(resulting.retrievables).to match({
            id: id_hash,
            name: name_hash
          })
        end
      end

      context 'with any other data type as value' do
        it 'raises exception' do
          expect { mocker.retrieve(id: 1, resource: :users) }.to raise_error(Persistence::Errors::OperationError)
        end
      end
    end
  end
end
