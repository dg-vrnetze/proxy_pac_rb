# frozen_string_literal: true
lib = ::File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'proxy_pac_rb/version'

Gem::Specification.new do |spec|
  spec.name        = 'proxy_pac_rb'
  spec.version     = ProxyPacRb::VERSION
  spec.authors     = ['Dennis Günnewig']
  spec.email       = ['dg1@ratiodata.de']
  spec.homepage    = 'https://github.com/dg-vrnetze/proxy_pac_rb'
  spec.summary     = 'Compress, lint and parse proxy auto-config files from commandline, rack-compatible applications and custom ruby code.'
  spec.description = <<-DESC
"proxy_pac_rb" is a gem to compress, lint and parse proxy auto-config files. It comes with a cli program, some rack middlewares and can be used from within ruby scripts as well. "proxy_pac_rb" uses a JavaScript runtime to evaulate a proxy auto-config file the same way a browser does to determine what proxy (if any at all) should a program use to connect to a server. You must install on of the supported JavaScript runtimes: therubyracer or therubyrhino
DESC

  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| ::File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'addressable', '~>2.3'
  spec.add_runtime_dependency 'activesupport', '>=4.1', '<5.2'
  spec.add_runtime_dependency 'uglifier', '>= 2.7.1'
  spec.add_runtime_dependency 'excon', '~> 0.45.3'
  spec.add_runtime_dependency 'contracts', '~> 0.9'
  spec.add_runtime_dependency 'thor', '~> 0.19'

  spec.required_ruby_version = '~> 2.3'
end
