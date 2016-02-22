module Vk
  class Group
    attr_reader :type
    attr_reader :types
    attr_reader :enums
    attr_reader :commands

    def initialize(type, enums: [])
      @type = type
      @types = []
      @enums = enums
      @commands = []
    end
  end
end