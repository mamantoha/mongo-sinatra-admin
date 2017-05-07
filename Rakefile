require 'rspec/core/rake_task'
require_relative 'app'
require_relative 'lib/deep_stringify'

RSpec::Core::RakeTask.new :specs do |task|
  task.rspec_opts = ['-c', '-f progress', '-r ./spec/spec_helper.rb']
  task.pattern = Dir['spec/**/*_spec.rb']
end

desc 'List defined routes'
task 'routes' do
  MongoAdmin::App.routes.each_pair do |method, list|
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

namespace :i18n do
  desc 'Create pseudo localization locale and generate locales/en-ZZ.yml. Texts are based on :en with checkmarks.'
  task :export_pseudo_i18n do
    symbol = "\u221a"
    en_tokens = I18n.backend.send(:translations)[:en].deep_stringify_hash!
    data = { 'en-ZZ' => en_tokens }.to_yaml.gsub(/&&&&&&/, "#{symbol}#{symbol}").gsub(/&&&&/, '').gsub(/&&&/, symbol).gsub(%r{(?<=\s)!ruby\/symbol }, ':')

    File.open('locales/en-ZZ.yml', 'w+') do |f|
      f.write(data)
    end
  end
end

task default: [:specs]
