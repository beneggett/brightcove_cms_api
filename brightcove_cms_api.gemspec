# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "brightcove_cms_api"
  spec.version       = "0.0.2"
  spec.authors       = ["Dilkhush Soni"]
  spec.email         = ["dilkhushsoni2010@gmail.com"]

  spec.summary       = %q{A simple wrapper around Brightcove's CMS API}
  spec.homepage      = "https://github.com/dilkhush/brightcove_cms_api"
  spec.license       = "MIT"

  spec.files         = ["lib/brightcove_cms_api.rb", "lib/brightcove_cms_api/video.rb", "lib/brightcove_cms_api/version.rb", "lib/brightcove_cms_api/errors.rb"]
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.required_ruby_version = '>= 2.2.6'

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_runtime_dependency "http"

end