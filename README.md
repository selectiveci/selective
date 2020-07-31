# Selective

Tools for collecting per test code coverage for ruby and rails applications

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'selective'
```

And then execute:

    $ bundle

## Usage

To collect code coverage using the Ruby's build in Coverage module,
it is important to begin code coverage before the application classes are loaded.
To accomplish this, it is recommended that the code below be run immediately at the
beginning of testing (usually in spec_helper).

```ruby
    require 'selective'
    Selective.initialize_collectors
```
