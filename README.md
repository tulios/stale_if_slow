## StaleIfSlow
[![Build Status](https://secure.travis-ci.org/tulios/stale_if_slow.png)](http://travis-ci.org/tulios/stale_if_slow)

Is a quality assurance tool for methods that access external services or have slow operations that could rely on stale cache in case of problem.

## How it works

StaleIfSlow creates a proxy around your methods that will cache the results after the call. The generated cache has two different durations that will be called 'fast cache' and 'slow cache'. After the first call, all following calls will return the cached value until fast cache expires. When this happens, another call of your method will be executed but only if it takes less than the configured timeout or the cached value will be returned. When the 'slow cache' expires the next call will happen without the interference of timeout, after that the whole cycle will restarts.

The cache store used will rely on [ActiveSupport::Cache::Store](http://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html) interface.

## Getting started

### Instalation

```console
gem install stale_if_slow
```

### Setup

If you are not using Rails:

```ruby
require "stale_if_slow"
```

TODO: Talk about each option

```ruby
StaleIfSlow.configure do
  cache_store ActiveSupport::Cache.lookup_store(:memory_store)
  logger Logger.new(STDOUT)
  logger_level Logger::ERROR
  timeout 0.4 # In seconds, accepts float numbers
  content_timeout 10.minutes
  stale_content_timeout 1.hour
end
```

You can now configure your classes like:

```ruby
class MyClass
  include StaleIfSlow::API    
  stale_if_slow :find_all
    
  def find_all
    # impl
  end
end
```

StaleIfSlow will __not__ initialize automatically, it will proxy your methods only when __initialize_stale_if_slow__ is called. You could call this method in the constructor, like:

```ruby
def initialize
  initialize_stale_if_slow
end
```

When cache value is written into cache it uses a default key provided by KeyGenerator, some times the default algorithm is not optimized for your methods because it take in account the parameters received by the method, so you are the best person to provide an implementation. It is possible to replace the default key generator for each proxied method using a class or a proc, like:

```ruby
class MyKeyGenerator
  def initialize method_name, reference
    @reference, @method_name = reference, method_name
  end
      
  def generate args
    # A better algorithm
  end
end
```

```ruby
stale_if_slow using_with_class: MyKeygenerator
stale_if_slow using_with_proc: lambda {||method_name, obj, args| # A better algorithm }
```

Sometimes is necessary to configure diferent times for some methods, to do that do like:

```ruby
stale_if_slow find_all: { timeout: 0.1, content_timeout: 30.seconds, stale_content_timeout: 5.minutes }
```

Each key of hash is optional, replace those that you need. When you are using this syntax and want to replace the key generator proceed like:

```ruby
stale_if_slow using_with_class: { timeout: 0.2, key: MyKeygenerator }
stale_if_slow using_with_proc: { timeout: 0.2, key: lambda {||method_name, obj, args| "" } }
```

### With Rails

TODO

## License

MIT License. Copyright 2012 Túlio Ornelas