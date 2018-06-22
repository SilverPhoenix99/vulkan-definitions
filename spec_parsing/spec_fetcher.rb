require 'open-uri'

filename = File.expand_path('../../vk.xml', __dir__)

open('https://github.com/KhronosGroup/Vulkan-Docs/blob/master/xml/vk.xml?raw=true') do |f|
  File.write(filename, f.read)
end
