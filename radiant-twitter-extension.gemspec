# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "radiant-twitter-extension"

Gem::Specification.new do |s|
  s.name        = "radiant-twitter-extension"
  s.version     = RadiantTwitterExtension::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = RadiantTwitterExtension::AUTHORS
  s.email       = RadiantTwitterExtension::EMAIL
  s.homepage    = RadiantTwitterExtension::URL
  s.summary     = RadiantTwitterExtension::SUMMARY
  s.description = RadiantTwitterExtension::DESCRIPTION

  s.add_dependency 'twitter', "~> 1.6.0"
  s.add_dependency 'bitly', "~> 0.6.1"

  ignores = if File.exist?('.gitignore')
    File.read('.gitignore').split("\n").inject([]) {|a,p| a + Dir[p] }
  else
    []
  end
  s.files         = Dir['**/*'] - ignores
  s.test_files    = Dir['test/**/*','spec/**/*','features/**/*'] - ignores
  # s.executables   = Dir['bin/*'] - ignores
  s.require_paths = ["lib"]

  s.post_install_message = %{
  Add this to your radiant project with:
    config.gem 'radiant-twitter-extension', :version => '~>#{RadiantTwitterExtension::VERSION}'
  }
end