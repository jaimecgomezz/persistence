# frozen_string_literal: true

RSpec.describe Persistence::Store::Operations::Capabilities::Retriever do
  let(:mocker) { Class.new { include Persistence::Store::Operations::Capabilities::Retriever }.new }

  describe '#retrieve' do
    it 'returns self' do
      expect(mocker.retrieve(:id)).to be(mocker)
    end

    context 'with positional argumemts' do
      context 'all being symbols' do
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

      context 'all being lists of symbols' do
        let(:resulting) { mocker.retrieve([:id, :ID], [:name, :NAME]) }

        it 'assumes a list of fields with their alias was provided' do
          expect(resulting.retrievables).to match({
            id: {
              alias: :ID,
              resource: nil
            },
            name: {
              alias: :NAME,
              resource: nil
            }
          })
        end

        context 'with :resource provided' do
          let(:resulting) { mocker.retrieve([:id, :ID], [:name, :NAME], resource: :users) }

          it 'includes resource un mapping' do
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
      end

      context 'being either symbols of lists of symbols' do
        let(:resulting) { mocker.retrieve(:id, [:name, :NAME]) }

        it 'assumes a list of fields with optional aliases was provided' do
          expect(resulting.retrievables).to match({
            id: {
              alias: nil,
              resource: nil
            },
            name: {
              alias: :NAME,
              resource: nil
            }
          })
        end

        context 'with :resource provided' do
          let(:resulting) { mocker.retrieve(:id, [:name, :NAME], resource: :users) }

          it 'includes resource in mapping' do
            expect(resulting.retrievables).to match({
              id: {
                alias: nil,
                resource: :users
              },
              name: {
                alias: :NAME,
                resource: :users
              }
            })
          end
        end
      end
    end

    context 'with keyword arguments' do
      context 'having symbols as values' do
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

        it 'respects them as custom field mappings' do
          expect(resulting.retrievables).to match({
            id: id_hash,
            name: name_hash
          })
        end
      end
    end
  end
end
