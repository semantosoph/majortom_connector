# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "majortom_connector/version"

Gem::Specification.new do |s|
  s.name        = "majortom_connector"
  s.version     = MajortomConnector::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Sven Windisch"]
  s.email       = ["sven.windisch@googlemail.com"]
  s.homepage    = ""
  s.summary     = %q{Connector gem for any MaJorToM-Server}
  s.description = %q{Provides easy and configurable access to MaJorToM-Server data stores.}

  s.rubyforge_project = "majortom_connector"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_dependency('httparty', '>= 0.7.4')
  s.post_install_message = %q{You have successfully installed the majortom_connector gem.\nDon't forget to put the majortom-server.yml into rails' config folder.}
end
