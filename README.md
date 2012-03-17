## StaleIfSlow
[![Build Status](https://secure.travis-ci.org/tulios/stale_if_slow.png)](http://travis-ci.org/tulios/stale_if_slow)

Is a quality assurance tool for methods that access external services or have slow operations that could rely on stale cache in case of problem.

## How it works

TODO

## Getting started

TODO

### With Rails

TODO

## Examples

```ruby
class Example1
  include StaleIfSlow::API  
  stale_if_slow :save
  stale_if_slow find: lambda {"key"}
  stale_if_slow find_all: ::Generator
    
  def save arg; end
  def find arg=nil; end
  def find_all; end
end
```

```ruby  
class Example2
  include StaleIfSlow::API
  stale_if_slow :save, :save, :save, :save
end
```

```ruby  
class Example3
  include StaleIfSlow::API
  stale_if_slow find_one: { timeout: 0.1, content_timeout: 30.seconds, stale_content_timeout: 5.minutes }
  stale_if_slow find_two: { timeout: 0.1, key: ::Generator }
  def find_one; end
  def find_two; end
end
```

## License

MIT License. Copyright 2012 Túlio Ornelas