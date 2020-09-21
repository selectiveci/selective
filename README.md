# Selective

Tools for collecting per test code coverage for ruby and rails applications

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'selective'
```

And then execute:

```bash
bundle
```

## Usage

To collect code coverage using the Ruby's build in Coverage module,
it is important to begin code coverage before the application classes are loaded.
To accomplish this, it is recommended that the code below be run immediately at the
beginning of testing (usually in spec_helper).

```ruby
require 'selective'
Selective.start
```
## Development

Pull requests are welcome. If you're adding a new feature, please [submit an issue](https://github.com/selectiveci/selective/issues/new) as a preliminary step; that way you can be (moderately) sure that your pull request will be accepted.

### Development Enviroment

For convenience we have created a Docker development environment. Run the following commands to use it:

```bash
bin/setup # Creates a .env and writes the output of `id -u` to it
docker-compose up -d # Starts containers in the background
docker-compose exec gem bash # Access the gem container's bash prompt 
```

### To contribute your code:

1. Fork it.
2. Create a topic branch `git checkout -b my_branch`
3. Make your changes and add an entry to the [CHANGELOG](CHANGELOG.md).
4. Commit your changes `git commit -am "Boom"`
5. Push to your branch `git push origin my_branch`
6. Send a [pull request](https://github.com/selectiveci/selective/pulls)

### Releasing

To release a new [patch] version:

1. With a clean working tree, use `rake bump:patch` to bump the version and stage the changes (you can make additional manual changes at this point if necessary).
2. Use `rake release` commit/tag the release, build the gem, and push to GitHub/RubyGems.

See `rake -T` for additional tasks.

### License

The Selective gem is MIT licensed. See the [LICENSE](https://raw.github.com/selectiveci/selective/master/LICENSE) file in this repository for details.
