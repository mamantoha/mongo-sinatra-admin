require 'rspec/core/rake_task'
require_relative 'app'

RSpec::Core::RakeTask.new :specs do |task|
  task.rspec_opts = ["-c", "-f progress", "-r ./spec/spec_helper.rb"]
  task.pattern = Dir['spec/**/*_spec.rb']
end

desc 'List defined routes'
task 'routes' do

  MongoAdmin::App::routes.each_pair do |method, list|
    puts ":: #{method} ::"
    routes = []
    list.each do |item|
      source = item[0].source
      item[1].each do |s|
        source.sub!(/\(.+?\)/, ':' + s)
      end
      source.gsub!(/(\\A|\\z)/, '')
      routes << source
    end
    puts routes.sort.join("\n")
    puts
  end
end

task default: [:specs]
