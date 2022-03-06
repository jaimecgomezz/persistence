# frozen_string_literal: true

RSpec.describe Persistence::Store::Operations::Capabilities::Paginator do
  let(:mocker) { Class.new { include Persistence::Store::Operations::Capabilities::Paginator }.new }

  let(:n) { rand(100) }
  let(:n2) { rand(100) }

  describe '#limit' do
    it 'returns self' do
      expect(mocker.limit(n)).to be(mocker)
    end

    context 'with method being called multiple times' do
      let(:resulting) { mocker.limit(n) }

      it 'overwrites previous configuration' do
        expect(resulting.limit(n2).pagination).to include({ limit: n2 })
      end
    end

    context 'with no arguments' do
      let(:resulting) { mocker.limit }

      it 'assigns default limit' do
        expect(resulting.pagination).to include({ limit: Persistence::Config::PageSize })
      end
    end

    context 'with positional argument' do
      context 'being a positive integer' do
        let(:resulting) { mocker.limit(n) }

        it 'assigns the given limit' do
          expect(resulting.pagination).to include({ limit: n })
        end
      end

      context 'being any other data type' do
        it 'raises exception' do
          expect { mocker.limit(-1) }.to raise_error(Persistence::Errors::OperationError)
        end
      end
    end
  end

  describe '#offset' do
    it 'returns self' do
      expect(mocker.offset(n)).to be(mocker)
    end

    context 'with method being called multiple times' do
      let(:resulting) { mocker.offset(n) }

      it 'overwrites previous configuration' do
        expect(resulting.offset(n2).pagination).to include({ offset: n2 })
      end
    end

    context 'with no arguments' do
      let(:resulting) { mocker.offset }

      it 'assigns default offset' do
        expect(resulting.pagination).to include({ offset: 0 })
      end
    end

    context 'with positional argument' do
      context 'being an integer' do
        let(:resulting) { mocker.offset(n) }

        it 'assigns the given offset' do
          expect(resulting.pagination).to include({ offset: n })
        end
      end

      context 'being any other data type' do
        it 'raises exception' do
          expect { mocker.offset(-1) }.to raise_error(Persistence::Errors::OperationError)
        end
      end
    end
  end

  describe '#first' do
    let(:prepared_mocker) { mocker.order(:created_at) }

    it 'returns self' do
      expect(prepared_mocker.first(n)).to be(mocker)
    end

    context 'with method being called multiple times' do
      let(:resulting) { prepared_mocker.first(n) }

      it 'overwrites previous configuration' do
        expect(resulting.first(n2).pagination).to include({ offset: 0, limit: n2 })
      end
    end

    context 'with no arguments' do
      let(:resulting) { prepared_mocker.first }

      it 'uses default pagination configuration' do
        expect(resulting.pagination).to include({ offset: 0, limit: Persistence::Config::PageSize })
      end
    end

    context 'with positional arguments' do
      context 'being an integer' do
        let(:resulting) { prepared_mocker.first(n) }

        it 'assigns expected pagination configuration' do
          expect(resulting.pagination).to include({ offset: 0, limit: n })
        end
      end

      context 'being any other data type' do
        it 'raises exception' do
          expect { mocker.first('a') }.to raise_error(Persistence::Errors::OperationError)
        end
      end
    end
  end

  describe '#last' do
    let(:prepared_mocker) { mocker.order(:created_at) }

    context 'without #order previously invoked' do
      it 'raises exception' do
        expect { mocker.last(n) }.to raise_error(Persistence::Errors::OperationError)
      end
    end

    it 'returns self' do
      expect(prepared_mocker.last(n)).to be(mocker)
    end

    context 'with method being called multiple times' do
      let(:resulting) { prepared_mocker.last(n) }

      it 'overwrites previous configuration' do
        expect(resulting.last(n2).pagination).to include({ limit: n2 })
      end
    end

    context 'with no arguments' do
      let(:resulting) { prepared_mocker.last }

      # TODO: prevent testing implementation details (:asc, :desc)
      it 'reverts existing orderings' do
        expect(resulting.orderings).to match([{ criteria: :created_at, order: :desc }])
      end

      it 'uses default pagination configuration' do
        expect(resulting.pagination).to include({ offset: 0, limit: Persistence::Config::PageSize })
      end
    end

    context 'with positional arguments' do
      context 'being an integer' do
        let(:resulting) { prepared_mocker.last(n) }

        # TODO: prevent testing implementation details (:asc, :desc)
        it 'reverts existing orderings' do
          expect(resulting.orderings).to match([{ criteria: :created_at, order: :desc }])
        end

        it 'assigns expected pagination configuration' do
          expect(resulting.pagination).to include({ offset: 0, limit: n })
        end
      end

      context 'being any other data type' do
        it 'raises exception' do
          expect { prepared_mocker.last('a') }.to raise_error(Persistence::Errors::OperationError)
        end
      end
    end
  end

  describe 'paginate' do
    let(:offset) { rand(100) }
    let(:offset2) { rand(100) }
    let(:limit) { rand(100) + 1 }
    let(:limit2) { rand(100) + 1 }

    it 'returns self' do
      expect(mocker.paginate).to be(mocker)
    end

    context 'when method being called multiple times' do
      let(:resulting) { mocker.paginate({ offset: offset, limit: limit }) }

      it 'overwrites previous configuration' do
        expect(resulting.paginate({
          offset: offset2,
          limit: limit2
        }).pagination).to include({ offset: offset2, limit: limit2 })
      end
    end

    context 'with no arguments' do
      let(:resulting) { mocker.paginate }

      it 'assigns default pagination configuration' do
        expect(resulting.pagination).to include({ offset: 0, limit: Persistence::Config::PageSize })
      end
    end

    context 'with positional arguments' do
      context 'being a hash' do
        let(:resulting) { mocker.paginate({ offset: offset, limit: limit }) }

        it 'assigns expected pagination configuration' do
          expect(resulting.pagination).to include({ offset: offset, limit: limit })
        end
      end
    end

    context 'with keyword arguments' do
      context 'being all integers' do
        let(:resulting) { mocker.paginate(offset: offset, limit: limit) }

        it 'assigns expected pagination configuration' do
          expect(resulting.pagination).to include({ offset: offset, limit: limit })
        end
      end

      context 'being any other data type' do
        it 'raises exception' do
          expect { mocker.paginate(offset: 'a', limit: 'a') }.to raise_error(Persistence::Errors::OperationError)
        end
      end
    end
  end
end
