RSpec.shared_context 'reactioner' do
  it 'is capable of reacting to events' do
    expect(mocker.class.ancestors).to include(Persistence::Store::Operations::Capabilities::Reactioner)
  end
end

RSpec.shared_context 'sourcer' do
  it 'is capable of defining its source' do
    expect(mocker.class.ancestors).to include(Persistence::Store::Operations::Capabilities::Sourcer)
  end
end

RSpec.shared_context 'filter' do
  it 'is capable of filtering' do
    expect(mocker.class.ancestors).to include(Persistence::Store::Operations::Capabilities::Filter)
  end
end

RSpec.shared_context 'joiner' do
  it 'is capable of joining resources' do
    expect(mocker.class.ancestors).to include(Persistence::Store::Operations::Capabilities::Joiner)
  end
end

RSpec.shared_context 'orderer' do
  it 'is capable of ordering results' do
    expect(mocker.class.ancestors).to include(Persistence::Store::Operations::Capabilities::Orderer)
  end
end

RSpec.shared_context 'paginator' do
  it 'is capable of paginating results' do
    expect(mocker.class.ancestors).to include(Persistence::Store::Operations::Capabilities::Paginator)
  end
end

RSpec.shared_context 'preloader' do
  it 'is capable of preloading associations' do
    expect(mocker.class.ancestors).to include(Persistence::Store::Operations::Capabilities::Preloader)
  end
end

RSpec.shared_context 'requirer' do
  it 'is capable of requiring resources' do
    expect(mocker.class.ancestors).to include(Persistence::Store::Operations::Capabilities::Requirer)
  end
end

RSpec.shared_context 'aggregator' do
  it 'is capable of aggregating results' do
    expect(mocker.class.ancestors).to include(Persistence::Store::Operations::Capabilities::Aggregator)
  end
end

RSpec.shared_context 'differentiator' do
  it 'is capable of differentiate results' do
    expect(mocker.class.ancestors).to include(Persistence::Store::Operations::Capabilities::Differentiator)
  end
end

RSpec.shared_context 'grouper' do
  it 'is capable of grouping results' do
    expect(mocker.class.ancestors).to include(Persistence::Store::Operations::Capabilities::Grouper)
  end
end

RSpec.shared_context 'retriever' do
  it 'is capable of retrieving attributes from results' do
    expect(mocker.class.ancestors).to include(Persistence::Store::Operations::Capabilities::Retriever)
  end
end

RSpec.shared_context 'setter' do
  it 'is capable of setting values on results' do
    expect(mocker.class.ancestors).to include(Persistence::Store::Operations::Capabilities::Setter)
  end
end

RSpec.shared_context 'discard_manager' do
  it 'is capable of managing discarded results' do
    expect(mocker.class.ancestors).to include(Persistence::Store::Operations::Capabilities::DiscardedManager)
  end

  it 'automatically excludes discarded results' do
    expect(mocker.global_filters.keys).to include(Persistence::Config::DISCARD_ATTRIBUTE)
  end
end
