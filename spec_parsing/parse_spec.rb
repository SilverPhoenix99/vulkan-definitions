require_relative '../lib/vulkan-definitions/spec/parser'
require_relative '../lib/vulkan-definitions/spec/compiler/ruby'

vk_spec = Vk::Spec.new(File.expand_path('../../vk.xml', __dir__))

Vk::Ruby::SpecCompiler.compile(vk_spec, File.expand_path('../lib/vulkan-definitions', __dir__))
