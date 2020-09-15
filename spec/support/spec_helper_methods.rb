module SpecHelperMethods
  def rspec_config_hooks_for(type)
    types = {
      before_suite: %i[@owner @before_suite_hooks],
      around_example: %i[@around_example_hooks @items_and_filters],
      after_suite: %i[@owner @after_suite_hooks]
    }

    hook_ptr = rspec_config.hooks

    types[type].each do |hook|
      hook_ptr = hook_ptr.instance_variable_get(hook)
    end

    hook_ptr.flatten.select do |item|
      next unless item.respond_to?(:block)
      item.block.source_location.first.include?("selective/lib")
    end
  end
end