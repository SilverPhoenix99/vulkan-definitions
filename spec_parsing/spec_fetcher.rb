body = `curl https://raw.githubusercontent.com/KhronosGroup/Vulkan-Docs/1.0/src/spec/vk.xml`
filename = File.expand_path('../../vk.xml', __dir__)
File.write(filename, body)
