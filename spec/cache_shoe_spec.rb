RSpec.describe 'when caching a service-style object' do
  Given { CacheShoe.config.cache.clear }
  Given(:thing) { Thing.new(123, 'name') }

  shared_examples_for 'caching' do
    context 'read caching' do
      context 'when nil, it should cache the nil' do
        Given { service_ex.read('INVALID_ID') }          # cache the nil
        When(:result) { service_ex.read('INVALID_ID') }  # now hit the cache
        Then  { service_ex.read_calls == 1 }
      end

      context 'when not nil, it should cache that' do
        Given { service_ex.create thing }
        When  { 2.times { service_ex.read(thing.id) } }
        Then  { service_ex.read_calls == 1 }
      end
    end

    context 'when creating it wipes the cache' do
      Given { service_ex.read(123) } # populate the cache with nil
      When { service_ex.create thing }
      Given(:result) { service_ex.read(123) }
      Then { result == thing } # verify cache was updated
      And  { service_ex.read_calls == 2 }
    end

    context 'when deleting it wipes the cache' do
      Given do
        service_ex.create thing
        # Populate the cache
        service_ex.read 123
      end

      When(:result) do
        service_ex.delete 123
        service_ex.read(123)
      end

      Then { service_ex.read_calls == 2 }
      And { result.nil? }
    end
  end

  context 'when using procs to clearing the cache' do
    Given(:service_ex) { ProcServiceExample.new }
    it_should_behave_like 'caching'
  end

  context 'when using symbol keys to clear the cache' do
    Given(:service_ex) { KeyServiceExample.new }
    it_should_behave_like 'caching'
  end

  context 'when omitting the model class' do
    Given(:service_ex) { DefaultModelServiceExample.new }
    it_should_behave_like 'caching'
  end

  context 'when caching multiple methods' do
    Given(:service_ex) { CacheTwoMethodsExample.new }
    it_should_behave_like 'caching'

    shared_context 'create thing and cache the reads' do
      Given do
        service_ex.create thing
        service_ex.read 123
        service_ex.read_hash(id: 123)
      end
    end

    context 'caching works' do
      include_context 'create thing and cache the reads'
      When(:result) do
        [service_ex.read(123), service_ex.read_hash(id: 123)]
      end

      Then { service_ex.read_hash_calls == 1 }
      And { service_ex.read_calls == 1 }
    end

    context 'cache clearing works' do
      include_context 'create thing and cache the reads'
      When(:result) do
        service_ex.delete 123
        [service_ex.read(123), service_ex.read_hash(id: 123)]
      end

      Then { service_ex.read_hash_calls == 2 }
      And { service_ex.read_calls == 2 }
      And { result.all?(&:nil?) }
    end
  end

  context 'when clearing multiple keys' do
    Given(:service_ex) { MultiKeyClearExample.new }
    it_should_behave_like 'caching'

    context 'ensure both keys are cleared' do
      Given do
        service_ex.read thing.id
        service_ex.read thing.name
      end

      When { service_ex.create thing }
      Given(:result) do
        [service_ex.read(thing.id), service_ex.read(thing.name)]
      end

      Then { result.all? { |result| result == thing } }
      And  { service_ex.read_calls == 4 }
    end
  end

  context 'when clearing a key cached by another service' do
    Given(:service_ex) { KeyServiceExample.new }
    Given(:clearing_service_ex) do
      SeparateCleaningServiceExample.new(service_ex)
    end
    Given do
      service_ex.create thing
      service_ex.read(thing.id)
    end

    When { clearing_service_ex.delete(thing.id) }

    Then { service_ex.read(thing.id).nil? }
    And  { service_ex.read_calls == 2 }
  end

  context 'when the cache methods raise' do
    Given(:service_ex) { BrokenExample.new }
    When(:result) { service_ex.create thing }
    Then { service_ex.create_calls == 1 }
  end

  context 'when read cache takes multiple parameters' do
    Given(:service_ex) { TwoParameterProcExample.new }
    Given { service_ex.read thing.id, thing.name } # cache
    When(:result) do
      service_ex.create thing
      service_ex.read thing.id, thing.name
    end

    Then { service_ex.read_calls == 2 }
  end
end
