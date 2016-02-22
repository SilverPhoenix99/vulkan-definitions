require_relative '../lib/vulkan-definitions/spec'

vk = Vk::Spec.new(File.expand_path('../../vk.xml', __dir__))
