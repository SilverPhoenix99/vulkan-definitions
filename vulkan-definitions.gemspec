require_relative 'lib/vulkan-definitions/version'

Gem::Specification.new do |s|
  s.name          = 'vulkan-definitions'
  s.version       = VK::Definitions::VERSION
  s.authors       = ['Silver Phoenix']
  s.email         = ['silver.phoenix99@gmail.com']
  s.summary       = %q{Vulkan definitions for Ruby.}
  s.description   = %q{Vulkan definitions for Ruby.}
  s.homepage      = 'https://github.com/SilverPhoenix99/vulkan-definitions'
  s.license       = 'MIT'
  s.files         = Dir['lib/**/*.rb']
  s.require_paths = ['lib']
  s.add_development_dependency 'oga', '~> 1.3'
  s.add_development_dependency 'erubis', '~> 2.7'
  s.add_development_dependency 'rspec', '~> 0'
  s.add_development_dependency 'facets', '~> 3'
end