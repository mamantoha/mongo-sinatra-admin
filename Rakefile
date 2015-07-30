require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new :specs do |task|
  task.rspec_opts = ["-c", "-f progress", "-r ./spec/spec_helper.rb"]
  task.pattern = Dir['spec/**/*_spec.rb']
end

task default: [:specs]
