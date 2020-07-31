# Selective

Tools for collecting per test code coverage for ruby and rails applications

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'selective'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install selective

## Usage

To collect code coverage using the Ruby's build in Coverage module,
it is important to begin code coverage before the application classes are loaded.
To accomplish this, it is recommended that the code below be run immediately at the
beginning of testing.

```ruby
    require 'test_coverage'
    
    Selective.configure do |config|
      # Setup a way to conditionally enable per test coverage collection
      config.enable_check = Proc.new { !ENV['TEST_COVERAGE_ENABLED'].nil? }
    
      # Configure what files to exclude from code coverage output
      config.file_exclusion_check = Proc.new { |file| file.include?('/gems/') || file.include?('/lib/ruby/') }
      
      # Decalre which coverage types should be enabled for collection
      # By default all collerctors are enabled
      config.enabled_collector_classes = [
        Selective::Collectors::RubyCoverageCollector,
        Selective::Collectors::ActiveRecord::AssociationCollector,
        Selective::Collectors::ActiveRecord::AttributeWriterCollector,
        Selective::Collectors::ActiveRecord::AttributeReaderCollector,
        Selective::Collectors::ActionView::RenderedTemplateCollector,
        Selective::Collectors::ActionView::AssetTagCollector,
        Selective::Collectors::Webpacker::WebpackerAppCollector
      ]
    
      # Set the location where coverage files will be written 
      config.coverage_path = '/tmp/coverage'
    
      # If using the WebpackerAppCollector, configure the paths where
      # webpacker apps can be found.  
      config.webpacker_app_locations = [
        File.join('app', 'javascript'),
      ]
    end
    
    # Initialize the coverage collectors which will setup any hooks that are
    # needed to collect coverage data 
    Selective.initialize_collectors
    
    include Selective::TestCoverageMethods
    
    # For minitest add setup and tear down steps that write the coverage
    # data after each test finishes running 
    setup :start_recording_code_coverage
    teardown :write_code_coverage_artifact
```
