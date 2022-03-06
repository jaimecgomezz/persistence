RSpec.shared_context 'transformer' do
  it 'defines transformer methods' do
    expect(instance).to respond_to(:one).with(1).argument
    expect(instance).to respond_to(:many).with(1).argument
  end
end
