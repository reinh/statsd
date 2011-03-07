# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
 
Gem::Specification.new do |s|
  s.name        = "statsd"
  s.version     = "0.0.1"
  s.authors     = ["Rein Henrichs"]
  s.email       = ["reinh@reinh.com"]
  s.homepage    = "https://github.com/reinh/statsd"
  s.summary     = "ruby statsd client"
  s.description = "A Ruby statsd client"
   
  s.files        = Dir.glob("{lib}/**/*") + %w(README.rdoc LICENSE.txt)
  s.require_paths = ["lib"]
end


