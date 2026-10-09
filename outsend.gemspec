# frozen_string_literal: true

require_relative "lib/outsend/version"

# The gemspec's name is the plugin's key.
Gem::Specification.new do |spec|
  spec.name = "outsend"
  spec.version = Outsend::VERSION
  spec.summary = "Outsend: send the CMS's email through Outsend with an API key set in Settings"
  spec.authors = ["Martin Business Consultants"]
  spec.homepage = "https://github.com/Martin-Business-Consultants/cms-outsend"
  spec.license = "FSL-1.1-MIT"
  spec.files = Dir["{app,config,db,lib}/**/*"]
  spec.required_ruby_version = ">= 3.3"
  spec.add_dependency "rails", ">= 8.1"
end
