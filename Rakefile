require 'rubygems'
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "statsd-ruby"
  gem.homepage = "http://github.com/reinh/statsd"
  gem.license = "MIT"
  gem.summary = %Q{A Statsd client in Ruby}
  gem.description = %Q{A Statsd client in Ruby}
  gem.email = "rein@phpfog.com"
  gem.authors = ["Rein Henrichs"]
  gem.add_development_dependency "minitest", ">= 0"
  gem.add_development_dependency "yard", "~> 0.6.0"
  gem.add_development_dependency "jeweler", "~> 1.5.2"
  gem.add_development_dependency "rcov", ">= 0"
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.verbose = true
end

require 'rcov/rcovtask'
Rcov::RcovTask.new do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.verbose = true
  spec.rcov_opts << "--exclude spec,gems"
end

task :default => :spec

require 'yard'
YARD::Rake::YardocTask.new
