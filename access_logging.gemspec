Gem::Specification.new do |s|
  s.name = "access_logging"
  s.summary = "Log access to models through your controllers."
  s.description = "Log access to models through your controllers."
  s.files = Dir["lib/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.version = "0.0.2"
  s.authors = ["Nick Ragaz"]
  s.email = "nick.ragaz@gmail.com"
  s.homepage = "http://github.com/nragaz/access_logging"
  
  s.add_dependency 'rails', '~> 3'
  s.add_dependency 'date_range_scopes'
  
  s.add_development_dependency 'sqlite3'
end
