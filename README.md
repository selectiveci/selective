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

### CI Setup

| Environment Variable       | Description |
|----------------------------|-------------|
| SELECTIVE_API_KEY          | Set to api key created on Selective CI |
| SELECTIVE_REPORT_CALLGRAPH | Set to `true` to enable coverage collection and reporting to Selective CI |
| SELECTIVE_SELECT_TESTS     | Set to `true` to enable test selection |

Typically, `SELECTIVE_REPORT_CALLGRAPH` and `SELECTIVE_SELECT_TESTS` would not set to `true` at the same time. `SELECTIVE_REPORT_CALLGRAPH` would be set to `true` when the test runs against the default branch. `SELECTIVE_SELECT_TESTS` would be set to `true` when the test suite is run against all other branches.

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

### License

The Selective gem is MIT licensed. See the [LICENSE](https://raw.github.com/selectiveci/selective/master/LICENSE) file in this repository for details.
