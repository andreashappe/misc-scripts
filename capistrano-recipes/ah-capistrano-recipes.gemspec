Gem::Specification.new do |s|
  s.name        = 'ah-capistrano-recipes'
  s.version     = '0.0.1'
  s.date        = '2012-11-30'
  s.summary     = "A collection of capistrano recipes for deploying to virtual servers"
  s.description = s.summary
  s.authors     = ["Andreas Happe"]
  s.email       = 'andreashappe@snikt.net'
  s.files       = Dir["lib/**/*.rb", "lib/templates/*", "tasks/*.rake"]
  s.homepage    = 'http://github.com/andreashappe/ah-capistrano-recipes'
  s.require_paths = ["lib"]
  s.extra_rdoc_files = ["README.md"]

  s.add_dependency "capistrano"
  s.add_dependency "capistrano-ext"
end
