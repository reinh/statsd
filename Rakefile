require 'rubygems'
require 'bundler/setup'

task :default => :spec

require 'jeweler'
Jeweler::Tasks.new do |gem|
  gem.name        = "statsd-ruby"
  gem.license     = "MIT"
  gem.homepage    = "http://github.com/jeremy/statsd-ruby"
  gem.summary     = "A Ruby StatsD client"
  gem.description = "A Ruby StatsD client"

  gem.email       = "rein@phpfog.com"
  gem.authors     = ["Rein Henrichs"]

  gem.add_development_dependency "minitest", ">= 0"
  gem.add_development_dependency "yard", "~> 0.6.0"
  gem.add_development_dependency "jeweler", "~> 1.8"
  gem.add_development_dependency "simplecov", ">= 0"
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.verbose = true
end

require 'yard'
YARD::Rake::YardocTask.new
