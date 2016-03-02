module Vk
  module ExtensionModule
    def version
      @version ||= ''.freeze
    end

    def commands
      @commands ||= {}.freeze
    end

    def constants
      @constants ||= {}.freeze
    end

    def enums
      @enums ||= {}.freeze
    end

    def structs
      @structs ||= {}.freeze
    end

    def types
      @types ||= {}.freeze
    end
  end
end